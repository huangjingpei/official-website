<template>
  <section class="section section-alt">
    <div class="container">
      <h2>技术方案</h2>
      <ThreeUpCarousel :items="solutions" @select="onSelect" />

      <div v-if="selected" class="card solution-detail">
        <h3>{{ selected.title }}</h3>
        <p class="meta">{{ selected.detail }}</p>
        <RouterLink class="download-link" to="/about">联系咨询</RouterLink>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'
import ThreeUpCarousel from '../components/ThreeUpCarousel.vue'

const solutions = [
  {
    key: 'webrtc',
    title: 'WebRTC 实时互动',
    description: '基于 WebRTC 构建低延迟音视频互动能力，适用于在线教育、会议和远程协作。',
    detail: '低延迟音视频、多人互动、弱网优化、端到端时延监控，适配 Web/移动/桌面多端接入。'
  },
  {
    key: 'remote',
    title: '远程桌面支持',
    description: '支持多终端远程控制与屏幕传输，兼顾性能与稳定性。',
    detail: '高质量屏幕采集与编码、输入控制、穿透/中继、权限与审计，适用于运维、售后、远程协作。'
  },
  {
    key: 'danmaku',
    title: '实时弹幕系统',
    description: '提供高并发弹幕与消息互动支持，适配直播和实时互动场景。',
    detail: '消息分发、房间/频道、限流与反垃圾、消息持久化与回放，支撑直播互动与社区讨论场景。'
  },
  {
    key: 'ai',
    title: 'AI 实时交互',
    description: '提供语音识别、文本交互、智能问答等 AI 能力接入方案。',
    detail: '语音/文本实时流式处理、工具调用与知识库接入，支持客服、陪练、助理等实时交互业务。'
  }
]

const route = useRoute()
const selectedKey = ref(route.query.focus || solutions[0].key)
const selected = computed(() => solutions.find((s) => s.key === selectedKey.value) || solutions[0])

const onSelect = (item) => {
  selectedKey.value = item.key
}
</script>
