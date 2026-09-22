<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { clearAuth, getAuthMe } from '../../services/api'

const route = useRoute()
const router = useRouter()
const items = [
  { to: '/console/downloads', label: '软件升级' },
  { to: '/console/news', label: '实时要闻' },
  { to: '/console/contacts', label: '客户留言' },
  { to: '/console/theme', label: '主题设置' },
  { to: '/console/password', label: '修改密码' }
]

const activePath = computed(() => route.path)

const username = ref('')
const needsPasswordChange = ref(false)
const getSkipFlag = () => window.sessionStorage.getItem('admin_pw_change_skip') === '1'
const showNeedsPassword = computed(() => needsPasswordChange.value && !getSkipFlag())

const currentLabel = computed(() => {
  const match = items.find((it) => activePath.value === it.to)
  return match?.label || '管理后台'
})

const refreshMe = async () => {
  try {
    const { data } = await getAuthMe()
    username.value = data?.username || ''
    needsPasswordChange.value = Boolean(data?.needsPasswordChange)
  } catch (error) {
    username.value = ''
    needsPasswordChange.value = false
  }
}

const logout = async () => {
  clearAuth()
  window.sessionStorage.removeItem('admin_pw_change_skip')
  await refreshMe()
  await router.push('/console/login')
}

onMounted(async () => {
  await refreshMe()
  window.addEventListener('auth-changed', refreshMe)
})

onUnmounted(() => {
  window.removeEventListener('auth-changed', refreshMe)
})
</script>

<template>
  <div class="console-app">
    <aside class="console-aside">
      <div class="console-aside-header">
        <div class="console-aside-title">管理后台</div>
        <div class="console-aside-subtitle">杭州栩文科技有限公司</div>
      </div>
      <nav class="console-nav">
        <RouterLink
          v-for="item in items"
          :key="item.to"
          :to="item.to"
          class="console-nav-item"
          :class="{ active: activePath === item.to }"
        >
          {{ item.label }}
        </RouterLink>
      </nav>
      <div class="console-aside-footer">入口：/console</div>
    </aside>

    <main class="console-main">
      <header class="console-topbar">
        <div class="console-topbar-title">{{ currentLabel }}</div>
        <div class="console-topbar-actions">
          <RouterLink class="console-topbar-link" to="/">返回官网</RouterLink>
          <RouterLink v-if="showNeedsPassword" class="console-topbar-badge" to="/console/password">需修改密码</RouterLink>
          <span class="console-topbar-meta">{{ username ? `账号：${username}` : '未登录' }}</span>
          <button v-if="username" class="console-btn console-btn-danger" type="button" @click="logout">退出登录</button>
        </div>
      </header>
      <div class="console-body">
        <router-view />
      </div>
    </main>
  </div>
</template>

<style scoped>
.console-app {
  min-height: 100vh;
  display: flex;
  background: #f3f4f6;
  color: #111827;
}

.console-aside {
  width: 240px;
  background: #ffffff;
  border-right: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
}

.console-aside-header {
  padding: 1.15rem 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.console-aside-title {
  font-weight: 750;
  font-size: 1.05rem;
}

.console-aside-subtitle {
  margin-top: 0.25rem;
  font-size: 0.85rem;
  color: #6b7280;
}

.console-nav {
  padding: 0.75rem 0.5rem;
  display: grid;
  gap: 0.25rem;
}

.console-nav-item {
  padding: 0.55rem 0.75rem;
  border-radius: 6px;
  color: #111827;
  border: 1px solid transparent;
}

.console-nav-item:hover {
  background: #f3f4f6;
}

.console-nav-item.active {
  background: #eef2ff;
  border-color: #c7d2fe;
  color: #1d4ed8;
}

.console-aside-footer {
  margin-top: auto;
  padding: 0.85rem 1rem;
  border-top: 1px solid #e5e7eb;
  color: #6b7280;
  font-size: 0.85rem;
}

.console-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.console-topbar {
  height: 54px;
  background: #ffffff;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1.1rem;
  gap: 1rem;
}

.console-topbar-title {
  font-weight: 650;
}

.console-topbar-actions {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.console-topbar-link {
  color: #1d4ed8;
}

.console-topbar-link:hover {
  text-decoration: underline;
}

.console-topbar-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.15rem 0.55rem;
  border-radius: 999px;
  background: #fef3c7;
  border: 1px solid #fcd34d;
  color: #92400e;
  font-size: 0.85rem;
}

.console-topbar-meta {
  color: #6b7280;
  font-size: 0.9rem;
}

.console-btn {
  border: 1px solid transparent;
  border-radius: 6px;
  padding: 0.35rem 0.7rem;
  cursor: pointer;
  font: inherit;
}

.console-btn:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

.console-btn-danger {
  background: #dc2626;
  color: #ffffff;
}

.console-btn-danger:hover {
  background: #b91c1c;
}

.console-body {
  padding: 1.1rem;
  min-width: 0;
}

@media (max-width: 860px) {
  .console-app {
    flex-direction: column;
  }

  .console-aside {
    width: 100%;
  }
}
</style>
