<template>
  <section class="hero">
    <div class="container">
      <p class="tag">官方技术支持平台</p>
      <h2>让 AI 与音视频能力快速落地到业务场景</h2>
      <p>
        杭州栩文科技有限公司聚焦实时互动、远程协作、弹幕系统与 AI 实时交互，为企业提供稳定可扩展的技术解决方案。
      </p>
    </div>
  </section>
  <section class="section section-alt">
    <div class="container">
      <h2 class="section-title">核心能力</h2>
      <ThreeUpCarousel :items="features" @select="onFeatureSelect" />
    </div>
  </section>
</template>

<script setup>
import ThreeUpCarousel from '../components/ThreeUpCarousel.vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const features = [
  { key: 'webrtc', title: 'WebRTC 实时互动', description: '支持低延迟音视频与多端互动体验。' },
  { key: 'remote', title: '远程桌面支持', description: '实现高质量远程控制与运维协作。' },
  { key: 'danmaku', title: '实时弹幕系统', description: '高并发消息分发与直播互动能力。' },
  { key: 'ai', title: 'AI 实时交互', description: '支持语音、文本和多模态交互体验。' }
]

const onFeatureSelect = (item) => {
  router.push({ name: 'solutions', query: { focus: item.key } })
}
</script>
