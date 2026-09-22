<template>
  <!-- Hero 首屏 -->
  <section class="hero">
    <div class="container">
      <p class="tag">AI × 音视频前沿技术平台</p>
      <h2>让 AI 与音视频能力快速赋能业务场景</h2>
      <p style="max-width: 680px; font-size: 1.15rem; line-height: 1.7; opacity: 0.92;">
        杭州栩文科技有限公司聚焦实时音视频互动、远程桌面控制、高并发弹幕系统与 AI 实时交互，为企业级客户提供稳定、高性能、可扩展的底层技术方案与客户端产品支持。
      </p>
      <div class="hero-actions">
        <RouterLink to="/solutions" class="btn-primary">
          探索技术方案
          <span style="font-size: 1.2rem;">→</span>
        </RouterLink>
        <RouterLink to="/downloads" class="btn-secondary">
          下载 Penclaw 工具
        </RouterLink>
      </div>
    </div>
  </section>

  <!-- 核心数据指标看板 (Metrics) -->
  <section class="metrics-section">
    <div class="container">
      <div class="metrics-grid">
        <div class="metric-card">
          <div class="metric-value">&lt; 150ms</div>
          <div class="metric-label">全球端到端时延</div>
          <div class="metric-desc">WebRTC 极速弱网抗丢包与抖动优化</div>
        </div>
        <div class="metric-card">
          <div class="metric-value">99.99%</div>
          <div class="metric-label">服务高可用性</div>
          <div class="metric-desc">多节点多机房容灾部署与动态负载</div>
        </div>
        <div class="metric-card">
          <div class="metric-value">千万级</div>
          <div class="metric-label">高并发消息分发</div>
          <div class="metric-desc">毫秒级弹幕分发与房间级广播架构</div>
        </div>
        <div class="metric-card">
          <div class="metric-value">全平台</div>
          <div class="metric-label">多端协同覆盖</div>
          <div class="metric-desc">Windows / macOS / Linux / 移动与 Web</div>
        </div>
      </div>
    </div>
  </section>

  <!-- 核心技术方案轮播 -->
  <section class="section section-alt">
    <div class="container">
      <div style="text-align: center; margin-bottom: 2rem;">
        <h2 class="section-title">核心技术方案</h2>
        <p style="color: var(--muted); margin: 0.4rem 0 0;">自主研发、低时延架构与端云协同处理技术</p>
      </div>
      <ThreeUpCarousel :items="features" @select="onFeatureSelect" />
    </div>
  </section>

  <!-- 典型落地场景 -->
  <section class="section">
    <div class="container">
      <div style="text-align: center; margin-bottom: 2rem;">
        <h2 class="section-title">典型业务场景</h2>
        <p style="color: var(--muted); margin: 0.4rem 0 0;">针对不同业务形态提供开箱即用与定制化集成方案</p>
      </div>
      <div class="scenarios-grid">
        <div class="scenario-card">
          <div class="scenario-icon">🎥</div>
          <h3>远程协同与在线会议</h3>
          <p>提供多方超清低延迟音视频通话、白板共享、屏幕广播与会议录制归档。</p>
        </div>
        <div class="scenario-card">
          <div class="scenario-icon">🖥️</div>
          <h3>远程技术支持与桌面控制</h3>
          <p>基于 Penclaw 核心的高帧率、无感输入响应远程桌面协助，支持内网穿透与跨平台操控。</p>
        </div>
        <div class="scenario-card">
          <div class="scenario-icon">💬</div>
          <h3>互动直播与高频弹幕</h3>
          <p>支撑千万级用户在线互动、实时点赞送礼、限流过滤与弹幕持久化回放系统。</p>
        </div>
        <div class="scenario-card">
          <div class="scenario-icon">🤖</div>
          <h3>AI 实时语音与虚拟人交互</h3>
          <p>流式语音识别 (ASR)、智能知识库大模型驱动与超低时延语音合成 (TTS) 端到端交互。</p>
        </div>
      </div>
    </div>
  </section>

  <!-- 快速行动 CTA 栏 -->
  <section class="section section-alt" style="text-align: center;">
    <div class="container">
      <h2>准备好加速您的音视频与 AI 业务了吗？</h2>
      <p style="color: var(--muted); max-width: 600px; margin: 0.8rem auto 1.8rem;">
        无论您需要标准化的客户端工具，还是深度的底层架构定制，我们的资深工程师团队都将竭诚为您服务。
      </p>
      <div style="display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap;">
        <RouterLink to="/about" class="btn-primary">立即预约咨询</RouterLink>
        <RouterLink to="/downloads" class="btn-secondary" style="color: var(--ink-0); border-color: var(--stroke);">
          浏览产品下载
        </RouterLink>
      </div>
    </div>
  </section>
</template>

<script setup>
import ThreeUpCarousel from '../components/ThreeUpCarousel.vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const features = [
  { key: 'webrtc', title: 'WebRTC 实时互动', description: '自研编解码与抗丢包算法，实现 <150ms 极低延迟多端互动体验。' },
  { key: 'remote', title: '远程桌面支持 (Penclaw)', description: '低开销桌面采集、智能硬件编解码与多平台远程运维协同。' },
  { key: 'danmaku', title: '实时弹幕消息引擎', description: '集群化发布订阅架构，支持亿级流量平稳吞吐与精准广播。' },
  { key: 'ai', title: 'AI 实时流式交互', description: '支持实时多模态交互、语音端到端识别与智能客服数字人赋能。' }
]

const onFeatureSelect = (item) => {
  router.push({ name: 'solutions', query: { focus: item.key } })
}
</script>
