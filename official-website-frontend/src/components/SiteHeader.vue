<template>
  <header class="site-header" :class="{ scrolled }">
    <div class="container nav-row">
      <div class="brand">
        <RouterLink to="/" class="brand-link">
          <img src="/favicon.svg" alt="杭州栩文科技 Logo" class="brand-logo" />
          <div class="brand-text">
            <h1>杭州栩文科技</h1>
            <p>AI × 音视频解决方案</p>
          </div>
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
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { setTheme, getTheme } from '../theme'

const isDrawerOpen = ref(false)
const scrolled = ref(false)
const theme = ref(getTheme() || document.documentElement.getAttribute('data-theme') || 'business')

const handleScroll = () => { scrolled.value = window.scrollY > 10 }

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
  window.addEventListener('scroll', handleScroll, { passive: true })
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>

<style scoped>
.brand-link {
  color: inherit;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  text-decoration: none;
}
.brand-link:hover {
  opacity: 0.95;
}
.brand-logo {
  width: 38px;
  height: 38px;
  border-radius: 9px;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(37, 99, 235, 0.25);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.brand-link:hover .brand-logo {
  transform: scale(1.06);
  box-shadow: 0 4px 12px rgba(56, 189, 248, 0.4);
}
.brand-text h1 {
  font-size: 1.15rem;
  margin: 0;
  line-height: 1.25;
}
.brand-text p {
  font-size: 0.75rem;
  margin: 0;
  color: var(--muted);
}
.scrolled {
  box-shadow: 0 2px 16px rgba(0, 0, 0, 0.18);
  transition: box-shadow 0.25s;
}
</style>
