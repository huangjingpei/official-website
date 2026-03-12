<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { changePassword, getAuthMe, getRole, setBasicAuth, setRole } from '../../services/api'

const loading = ref(false)
const errorMessage = ref('')
const role = ref(getRole())
const me = ref(null)
const needsPasswordChange = ref(false)

const isAdmin = computed(() => role.value === 'ADMIN')

const form = reactive({
  newPassword: '',
  confirmPassword: ''
})

const refreshMe = async () => {
  try {
    const { data } = await getAuthMe()
    me.value = data
    const roles = Array.isArray(data.roles) ? data.roles : []
    const nextRole = roles.includes('ROLE_ADMIN') ? 'ADMIN' : 'USER'
    role.value = nextRole
    setRole(nextRole)
    needsPasswordChange.value = Boolean(data.needsPasswordChange)
  } catch (error) {
    me.value = null
    role.value = getRole()
    needsPasswordChange.value = false
  }
}

const onSkip = () => {
  window.sessionStorage.setItem('admin_pw_change_skip', '1')
  needsPasswordChange.value = false
  errorMessage.value = ''
}

const onChange = async () => {
  if (!form.newPassword || form.newPassword.length < 8) {
    errorMessage.value = '新密码至少 8 位。'
    return
  }
  if (form.newPassword !== form.confirmPassword) {
    errorMessage.value = '两次输入的新密码不一致。'
    return
  }
  loading.value = true
  try {
    await changePassword(form.newPassword)
    setBasicAuth(me.value?.username || loginForm.username, form.newPassword)
    window.sessionStorage.removeItem('admin_pw_change_skip')
    form.newPassword = ''
    form.confirmPassword = ''
    await refreshMe()
    errorMessage.value = ''
  } catch (error) {
    errorMessage.value = error?.response?.data?.message || '密码修改失败，请稍后重试。'
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await refreshMe()
})
</script>

<template>
  <div class="console-page">
    <div v-if="errorMessage" class="console-alert console-alert-error">{{ errorMessage }}</div>

    <div v-if="!isAdmin" class="console-panel">
      <div class="console-panel-title">需要登录</div>
      <div class="meta">请先前往管理后台登录页完成登录。</div>
      <div class="console-actions">
        <RouterLink class="console-topbar-link" to="/console/login">前往登录</RouterLink>
      </div>
    </div>

    <div v-else class="console-panel">
      <div class="console-panel-title">修改密码</div>
      <div v-if="needsPasswordChange" class="console-alert console-alert-warn">
        检测到你仍在使用初始密码，建议尽快修改。
        <button class="console-link-btn" type="button" @click="onSkip">跳过，下次设置</button>
      </div>

      <div class="console-form">
        <div class="console-field">
          <div class="console-label">新密码</div>
          <input
            v-model="form.newPassword"
            class="console-input"
            placeholder="至少 8 位"
            type="password"
            autocomplete="new-password"
          />
        </div>
        <div class="console-field">
          <div class="console-label">确认新密码</div>
          <input
            v-model="form.confirmPassword"
            class="console-input"
            placeholder="再次输入新密码"
            type="password"
            autocomplete="new-password"
            @keydown.enter="onChange"
          />
        </div>
        <div class="console-actions">
          <button class="console-btn console-btn-primary" :disabled="loading" type="button" @click="onChange">保存修改</button>
        </div>
      </div>
    </div>
  </div>
</template>
