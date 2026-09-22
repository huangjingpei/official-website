<template>
  <header class="site-header">
    <div class="container nav-row">
      <div class="brand">
        <RouterLink to="/" class="brand-link">
          <h1>杭州栩文科技</h1>
          <p>AI × 音视频解决方案</p>
        </RouterLink>
      </div>

      <!-- 桌面端导航 -->
      <nav class="nav-links">
        <RouterLink to="/">首页</RouterLink>
        <RouterLink to="/company">公司概况</RouterLink>
        <RouterLink to="/solutions">技术方案</RouterLink>
        <RouterLink to="/news">实时要闻</RouterLink>
        <RouterLink to="/downloads">软件下载</RouterLink>
        <RouterLink to="/about">关于我们</RouterLink>
      </nav>

      <!-- 桌面端操作区 -->
      <div class="nav-actions">
        <button class="theme-toggle" type="button" @click="toggleTheme" :title="themeTitle">
          {{ themeLabel }}
        </button>
        <RouterLink to="/about" class="nav-cta-btn">技术咨询</RouterLink>
        
        <!-- 移动端汉堡按钮 -->
        <button class="mobile-toggle" type="button" @click="isDrawerOpen = true" aria-label="打开菜单">
          <svg viewBox="0 0 24 24" fill="none">
            <path d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </div>
    </div>

    <!-- 移动端抽屉遮罩与侧边菜单 -->
    <div class="drawer-backdrop" :class="{ active: isDrawerOpen }" @click="isDrawerOpen = false"></div>
    <aside class="mobile-drawer" :class="{ active: isDrawerOpen }">
      <div class="drawer-header">
        <strong>网站导航</strong>
        <button class="drawer-close" type="button" @click="isDrawerOpen = false">×</button>
      </div>
      <nav class="drawer-nav">
        <RouterLink to="/" @click="isDrawerOpen = false">首页</RouterLink>
        <RouterLink to="/company" @click="isDrawerOpen = false">公司概况</RouterLink>
        <RouterLink to="/solutions" @click="isDrawerOpen = false">技术方案</RouterLink>
        <RouterLink to="/news" @click="isDrawerOpen = false">实时要闻</RouterLink>
        <RouterLink to="/downloads" @click="isDrawerOpen = false">软件下载</RouterLink>
        <RouterLink to="/about" @click="isDrawerOpen = false">关于我们</RouterLink>
      </nav>
      <div style="margin-top: auto; padding-top: 1.5rem; border-top: 1px solid var(--stroke); display: flex; flex-direction: column; gap: 0.8rem;">
        <button class="theme-toggle" style="width: 100%; justify-content: center;" type="button" @click="toggleTheme">
          {{ themeLabel }}
        </button>
        <RouterLink to="/about" class="nav-cta-btn" style="width: 100%; text-align: center;" @click="isDrawerOpen = false">
          立即咨询需求
        </RouterLink>
      </div>
    </aside>
  </header>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { setTheme, getTheme } from '../theme'

const isDrawerOpen = ref(false)
const theme = ref(getTheme() || document.documentElement.getAttribute('data-theme') || 'business')

const update = () => {
  theme.value = document.documentElement.getAttribute('data-theme') || 'business'
}

const themeLabel = computed(() => {
  if (theme.value === 'dark') return '🌓 极客黑'
  if (theme.value === 'cute') return '🌸 可爱风'
  return '☀️ 科技白'
})

const themeTitle = computed(() => '点击切换主题模式')

const toggleTheme = () => {
  // 轮转切换: business (科技白) -> dark (极客黑) -> cute (可爱) -> business
  let next = 'business'
  if (theme.value === 'business') next = 'dark'
  else if (theme.value === 'dark') next = 'cute'
  else next = 'business'

  setTheme(next)
  theme.value = next
}

onMounted(() => {
  update()
})
</script>

<style scoped>
.brand-link {
  color: inherit;
  display: block;
}
.brand-link:hover {
  opacity: 0.95;
}
</style>
