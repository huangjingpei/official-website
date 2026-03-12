<template>
  <header class="site-header">
    <div class="container nav-row">
      <div class="brand">
        <h1>栩文科技</h1>
        <p>AI × 音视频解决方案</p>
      </div>
      <nav class="nav-links">
        <RouterLink to="/">首页</RouterLink>
        <RouterLink to="/company">公司概况</RouterLink>
        <RouterLink to="/solutions">技术方案</RouterLink>
        <RouterLink to="/news">实时要闻</RouterLink>
        <RouterLink to="/downloads">软件下载</RouterLink>
        <RouterLink to="/about">关于我们</RouterLink>
        <button class="theme-toggle" type="button" @click="toggleTheme">{{ themeLabel }}</button>
      </nav>
    </div>
  </header>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { setTheme } from '../theme'

const theme = ref(document.documentElement.getAttribute('data-theme') || 'business')

const update = () => {
  theme.value = document.documentElement.getAttribute('data-theme') || 'business'
}

const themeLabel = computed(() => (theme.value === 'cute' ? '主题：可爱' : '主题：商务'))

const toggleTheme = () => {
  const next = theme.value === 'cute' ? 'business' : 'cute'
  setTheme(next)
  theme.value = next
}

onMounted(() => {
  update()
})
</script>
