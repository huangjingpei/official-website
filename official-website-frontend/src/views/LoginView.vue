<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { changePassword, clearAuth, getAuthMe, getRole, isAuthed, setBasicAuth, setRole } from '../services/api'

const router = useRouter()
const route = useRoute()

const loading = ref(false)
const errorMessage = ref('')
const me = ref(null)
const role = ref(getRole())
const needsPasswordChange = ref(false)
const showChangePrompt = ref(false)

const form = reactive({
  username: '',
  password: ''
})

const changeForm = reactive({
  newPassword: '',
  confirmPassword: ''
})

const isLoggedIn = computed(() => isAuthed() && Boolean(role.value))
const isAdmin = computed(() => role.value === 'ADMIN')

const getSkipFlag = () => window.sessionStorage.getItem('admin_pw_change_skip') === '1'

const refreshMe = async () => {
  try {
    const { data } = await getAuthMe()
    me.value = data
    const roles = Array.isArray(data.roles) ? data.roles : []
    const nextRole = roles.includes('ROLE_ADMIN') ? 'ADMIN' : 'USER'
    role.value = nextRole
    setRole(nextRole)
    needsPasswordChange.value = Boolean(data.needsPasswordChange)
    showChangePrompt.value = nextRole === 'ADMIN' && needsPasswordChange.value && !getSkipFlag()
    errorMessage.value = ''
  } catch (error) {
    me.value = null
    role.value = getRole()
    needsPasswordChange.value = false
    showChangePrompt.value = false
  }
}

const resolveRedirect = () => {
  const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : ''
  if (redirect.startsWith('/') && !redirect.startsWith('/login')) return redirect
  if (isAdmin.value) return '/console/downloads'
  return '/'
}

const openChangePassword = () => {
  window.sessionStorage.removeItem('admin_pw_change_skip')
  showChangePrompt.value = true
}

const closeChangePassword = () => {
  showChangePrompt.value = false
  changeForm.newPassword = ''
  changeForm.confirmPassword = ''
}

const onSkipChangePassword = async () => {
  window.sessionStorage.setItem('admin_pw_change_skip', '1')
  showChangePrompt.value = false
  await router.push(resolveRedirect())
}

const onChangePassword = async () => {
  if (!changeForm.newPassword || changeForm.newPassword.length < 8) {
    errorMessage.value = '新密码至少 8 位。'
    return
  }
  if (changeForm.newPassword !== changeForm.confirmPassword) {
    errorMessage.value = '两次输入的新密码不一致。'
    return
  }
  loading.value = true
  try {
    await changePassword(changeForm.newPassword)
    setBasicAuth(form.username, changeForm.newPassword)
    window.sessionStorage.removeItem('admin_pw_change_skip')
    changeForm.newPassword = ''
    changeForm.confirmPassword = ''
    await refreshMe()
    showChangePrompt.value = false
    await router.push(resolveRedirect())
  } catch (error) {
    errorMessage.value = error?.response?.data?.message || '密码修改失败，请稍后重试。'
  } finally {
    loading.value = false
  }
}

const onLogin = async () => {
  loading.value = true
  try {
    setBasicAuth(form.username, form.password)
    await refreshMe()
    if (!isAuthed()) {
      throw new Error('not_authed')
    }
    if (showChangePrompt.value) return
    await router.push(resolveRedirect())
  } catch (error) {
    clearAuth()
    errorMessage.value = '登录失败，请检查用户名密码。'
  } finally {
    loading.value = false
    form.password = ''
  }
}

const onLogout = async () => {
  clearAuth()
  window.sessionStorage.removeItem('admin_pw_change_skip')
  me.value = null
  role.value = null
  needsPasswordChange.value = false
  showChangePrompt.value = false
  await router.push('/')
}

onMounted(async () => {
  await refreshMe()
})
</script>

<template>
  <section class="section">
    <div class="container">
      <h2>用户登录</h2>
      <p class="meta">登录后可访问管理员上传页面（administrator 权限）与后续扩展的会员功能。</p>

      <div v-if="errorMessage" class="meta">{{ errorMessage }}</div>

      <div v-if="showChangePrompt" class="card">
        <div class="alert alert-warn">
          <p class="alert-title">建议修改管理员初始密码</p>
          <p class="alert-text">检测到你正在使用初始密码。修改后将提升安全性。</p>
          <div class="form-grid">
            <input
              v-model="changeForm.newPassword"
              placeholder="新密码（至少 8 位）"
              type="password"
              autocomplete="new-password"
            />
            <input
              v-model="changeForm.confirmPassword"
              placeholder="确认新密码"
              type="password"
              autocomplete="new-password"
              @keydown.enter="onChangePassword"
            />
          </div>
          <div class="form-actions" style="margin-top: 0.85rem">
            <button class="btn" :disabled="loading" type="button" @click="onChangePassword">修改密码</button>
            <button class="btn btn-secondary" :disabled="loading" type="button" @click="onSkipChangePassword">跳过，下次设置</button>
            <button class="btn btn-ghost" :disabled="loading" type="button" @click="closeChangePassword">暂不修改</button>
          </div>
        </div>
      </div>

      <div v-else-if="isLoggedIn" class="card">
        <h3>当前已登录</h3>
        <p class="meta">账号：{{ me?.username || '已验证' }}</p>
        <p class="meta">角色：{{ isAdmin ? '管理员' : '用户' }}</p>
        <div class="form-actions" style="margin-top: 0.85rem">
          <button v-if="isAdmin" class="btn btn-secondary" type="button" @click="openChangePassword">修改密码</button>
          <button class="btn btn-danger" type="button" @click="onLogout">退出登录</button>
        </div>
      </div>

      <div v-else class="card">
        <h3>账号密码</h3>
        <div class="contact-form">
          <input v-model="form.username" placeholder="用户名" autocomplete="username" />
          <input
            v-model="form.password"
            placeholder="密码"
            type="password"
            autocomplete="current-password"
            @keydown.enter="onLogin"
          />
          <button class="btn" :disabled="loading" type="button" @click="onLogin">登录</button>
        </div>
      </div>
    </div>
  </section>
</template>
