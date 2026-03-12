<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { clearAuth, getAuthMe, getRole, isAuthed, setBasicAuth, setRole } from '../../services/api'

const router = useRouter()
const route = useRoute()

const loading = ref(false)
const errorMessage = ref('')
const role = ref(getRole())

const form = reactive({
  username: '',
  password: ''
})

const isAdmin = computed(() => role.value === 'ADMIN')

const resolveRedirect = () => {
  const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : ''
  if (redirect.startsWith('/console/login')) return '/console/downloads'
  if (redirect.startsWith('/console')) return redirect
  return '/console/downloads'
}

const refreshMe = async () => {
  const { data } = await getAuthMe()
  const roles = Array.isArray(data.roles) ? data.roles : []
  const nextRole = roles.includes('ROLE_ADMIN') ? 'ADMIN' : 'USER'
  role.value = nextRole
  setRole(nextRole)
  return nextRole
}

const onLogin = async () => {
  loading.value = true
  try {
    setBasicAuth(form.username, form.password)
    const nextRole = await refreshMe()
    if (nextRole !== 'ADMIN') {
      clearAuth()
      errorMessage.value = '当前账号没有管理员权限。'
      return
    }
    errorMessage.value = ''
    await router.replace(resolveRedirect())
  } catch (error) {
    clearAuth()
    errorMessage.value = '登录失败，请检查用户名密码。'
  } finally {
    loading.value = false
    form.password = ''
  }
}

onMounted(async () => {
  if (!isAuthed()) return
  try {
    const nextRole = await refreshMe()
    if (nextRole === 'ADMIN') {
      await router.replace(resolveRedirect())
    } else {
      clearAuth()
    }
  } catch {
    clearAuth()
  }
})
</script>

<template>
  <div class="console-login">
    <div class="console-login-shell">
      <section class="console-login-left">
        <div class="console-login-left-inner">
          <div class="console-login-badge">Console</div>
          <div class="console-login-title">管理后台</div>
          <div class="console-login-subtitle">杭州栩文科技有限公司</div>
          <div class="console-login-desc">AI 驱动 · 音视频技术赋能 · 让业务更高效</div>
        </div>
      </section>

      <section class="console-login-right">
        <div class="console-login-card">
          <div class="console-login-card-title">登录</div>
          <div class="console-login-card-subtitle">请输入管理员账号密码</div>

          <div v-if="errorMessage" class="console-alert console-alert-error">{{ errorMessage }}</div>

          <div class="console-form console-login-form">
            <div class="console-field">
              <div class="console-label">用户名</div>
              <input v-model="form.username" class="console-input" placeholder="administrator" autocomplete="username" />
            </div>
            <div class="console-field">
              <div class="console-label">密码</div>
              <input
                v-model="form.password"
                class="console-input"
                placeholder="请输入密码"
                type="password"
                autocomplete="current-password"
                @keydown.enter="onLogin"
              />
            </div>
            <div class="console-actions console-login-actions">
              <button class="console-btn console-btn-primary" :disabled="loading" type="button" @click="onLogin">
                {{ loading ? '登录中...' : '登录' }}
              </button>
              <RouterLink class="console-topbar-link" to="/">返回官网</RouterLink>
            </div>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>
