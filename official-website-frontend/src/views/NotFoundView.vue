<template>
  <section class="section" style="min-height:70vh;display:flex;align-items:center;justify-content:center;text-align:center;">
    <div class="container">
      <div style="font-size:5rem;line-height:1;margin-bottom:1rem;">404</div>
      <h2 style="margin:0 0 .8rem;color:var(--ink-0);">页面不见了</h2>
      <p style="color:var(--muted);max-width:400px;margin:0 auto 2rem;font-size:1.05rem;">
        您访问的页面不存在，可能已被移动或删除。
      </p>
      <div style="display:flex;gap:1rem;justify-content:center;flex-wrap:wrap;">
        <RouterLink to="/" class="btn-primary">回到首页</RouterLink>
        <RouterLink to="/about" class="btn-secondary" style="color:var(--ink-0);border-color:var(--stroke);">联系我们</RouterLink>
      </div>
    </div>
  </section>
</template>

<script setup>
import { RouterLink } from 'vue-router'
</script>
