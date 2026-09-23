<script setup>
import { ref } from 'vue'
import { setTheme, getTheme } from '../../theme'

const current = ref(getTheme() || 'business')

const themes = [
  {
    key: 'business',
    name: '☀️ 科技白',
    desc: '明亮清爽，适合商务场景',
    preview: 'linear-gradient(135deg,#1d4ed8,#0f172a)'
  },
  {
    key: 'dark',
    name: '🌙 极客黑',
    desc: '深色沉浸，护眼科技风',
    preview: 'linear-gradient(135deg,#0369a1,#090d16)'
  },
  {
    key: 'cute',
    name: '🌸 可爱风',
    desc: '粉紫高饱和，活泼亲切',
    preview: 'linear-gradient(135deg,#fb7185,#1e1b4b)'
  }
]

const apply = (key) => {
  setTheme(key)
  current.value = key
}
</script>

<template>
  <div class="console-page">
    <div class="console-page-header">
      <div class="console-page-title">主题设置</div>
      <div class="meta">切换网站全局配色主题，即时预览</div>
    </div>

    <div class="console-panel">
      <div class="console-panel-title">选择主题</div>
      <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:1rem;margin-top:.8rem;">
        <div
          v-for="t in themes"
          :key="t.key"
          class="theme-card"
          :class="{ active: current === t.key }"
          @click="apply(t.key)"
        >
          <div class="theme-preview" :style="{ background: t.preview }"></div>
          <div class="theme-info">
            <div class="theme-name">{{ t.name }}</div>
            <div class="theme-desc">{{ t.desc }}</div>
          </div>
          <div v-if="current === t.key" class="theme-badge">✓ 当前</div>
        </div>
      </div>
      <p style="margin-top:1.2rem;font-size:.85rem;color:#64748b;">
        主题选择会实时应用到整个网站，并自动保存到浏览器本地存储。
      </p>
    </div>
  </div>
</template>

<style scoped>
.theme-card {
  border: 2px solid #e2e8f0; border-radius: 12px; overflow: hidden; cursor: pointer;
  transition: border-color .2s, box-shadow .2s; position: relative;
}
.theme-card:hover { border-color: #93c5fd; box-shadow: 0 4px 16px rgba(37,99,235,.15); }
.theme-card.active { border-color: #1d4ed8; box-shadow: 0 0 0 3px rgba(29,78,216,.18); }

.theme-preview { height: 72px; }
.theme-info { padding: .8rem 1rem .9rem; }
.theme-name { font-weight: 700; font-size: .95rem; color: #1e293b; }
.theme-desc { font-size: .8rem; color: #64748b; margin-top: .2rem; }

.theme-badge {
  position: absolute; top: .5rem; right: .5rem;
  background: #1d4ed8; color: #fff; font-size: .72rem; font-weight: 700;
  border-radius: 20px; padding: .15rem .5rem;
}
</style>
