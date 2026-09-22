<template>
  <div class="site-float-widget">
    <!-- 微信 / QQ 咨询二维码浮窗 -->
    <div class="float-btn" title="扫码咨询企业客服">
      <svg viewBox="0 0 24 24">
        <path d="M4 4h7v7H4V4zm2 2v3h3V6H6zm7-2h7v7h-7V4zm2 2v3h3V6h-3zM4 13h7v7H4v-7zm2 2v3h3v-3H6zm10-1h-2v2h2v-2zm-3 2h2v2h-2v-2zm5 0h2v2h-2v-2zm-2 2h2v2h-2v-2zm2 2h2v2h-2v-2z" />
      </svg>
      <div class="qr-popup">
        <div class="qr-placeholder">
          <!-- 优雅的微信二维码图形指示 -->
          <svg viewBox="0 0 100 100" style="width: 80px; height: 80px; fill: var(--accent);">
            <path d="M38 18c-14.4 0-26 10.1-26 22.5 0 7.4 4.1 13.9 10.6 18-.5 2.1-2.1 6.5-2.4 7.4-.3 1.1.2 1.3 1 .8 1.4-.9 6.8-4.7 8.7-6 2.6.7 5.3 1.1 8.1 1.1 1.2 0 2.4-.1 3.6-.2-1-.8-1.6-1.8-1.6-3 0-11.4 11-20.6 24.6-20.6 1 0 2 .1 3 .2C73 26.6 61.3 18 38 18zm-8 11.5c1.9 0 3.5 1.6 3.5 3.5s-1.6 3.5-3.5 3.5-3.5-1.6-3.5-3.5 1.6-3.5 3.5-3.5zm16 0c1.9 0 3.5 1.6 3.5 3.5s-1.6 3.5-3.5 3.5-3.5-1.6-3.5-3.5 1.6-3.5 3.5-3.5z" />
            <path d="M63 42c-12.7 0-23 8.7-23 19.5 0 6.3 3.6 12 9.2 15.6-.4 1.8-1.8 5.6-2.1 6.4-.3.9.2 1.1.9.7 1.2-.8 5.9-4.1 7.5-5.2 2.3.6 4.7 1 7.5 1 12.7 0 23-8.7 23-19.5S75.7 42 63 42zm-7 10c1.7 0 3 1.3 3 3s-1.3 3-3 3-3-1.3-3-3 1.3-3 3-3zm14 0c1.7 0 3 1.3 3 3s-1.3 3-3 3-3-1.3-3-3 1.3-3 3-3z" />
          </svg>
        </div>
        <p>微信扫一扫 · 专家支持</p>
        <span style="font-size: 0.75rem; color: var(--muted); display: block; margin-top: 0.2rem;">客服QQ：278225113</span>
      </div>
    </div>

    <!-- 电话直达 -->
    <a href="tel:13454118762" class="float-btn" title="拨打客服手机：13454118762">
      <svg viewBox="0 0 24 24">
        <path d="M6.62 10.79a15.053 15.053 0 006.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z" />
      </svg>
    </a>

    <!-- 平滑回到顶部 -->
    <button v-show="showBackTop" class="float-btn" type="button" title="回到顶部" @click="scrollToTop">
      <svg viewBox="0 0 24 24">
        <path d="M12 4l-8 8h5v8h6v-8h5z" />
      </svg>
    </button>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, ref } from 'vue'

const showBackTop = ref(false)

const handleScroll = () => {
  showBackTop.value = window.scrollY > 240
}

const scrollToTop = () => {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll, { passive: true })
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>
