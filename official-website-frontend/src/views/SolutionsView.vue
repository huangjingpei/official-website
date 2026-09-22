<template>
  <section class="section section-alt">
    <div class="container">
      <div style="text-align: center; margin-bottom: 2rem;">
        <h2>技术解决方案</h2>
        <p style="color: var(--muted); margin: 0.4rem 0 0;">
          凝聚杭州栩文科技在音视频传输、网络打洞与人工智能领域的深度积累
        </p>
      </div>

      <!-- 方案轮播选择 -->
      <ThreeUpCarousel :items="solutions" @select="onSelect" />

      <!-- 选中方案详尽架构与参数面板 -->
      <div v-if="selected" class="card solution-detail" style="margin-top: 2rem; padding: 2rem;">
        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem;">
          <div>
            <h3 style="font-size: 1.6rem; margin: 0 0 0.5rem; color: var(--ink-0);">{{ selected.title }}</h3>
            <p style="color: var(--muted); font-size: 1.05rem; margin: 0;">{{ selected.description }}</p>
          </div>
          <RouterLink class="nav-cta-btn" to="/about">
            咨询此方案方案落地 →
          </RouterLink>
        </div>

        <hr style="border: none; border-top: 1px solid var(--stroke); margin: 1.5rem 0;" />

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem;">
          <!-- 技术亮点 -->
          <div>
            <h4 style="margin: 0 0 0.8rem; color: var(--accent);">核心架构特性</h4>
            <p class="meta" style="line-height: 1.8;">{{ selected.detail }}</p>
          </div>

          <!-- 技术参数表 -->
          <div>
            <h4 style="margin: 0 0 0.8rem; color: var(--accent);">核心性能指标</h4>
            <div style="background: var(--bg-0); padding: 1rem; border-radius: 8px; border: 1px solid var(--stroke); display: grid; gap: 0.6rem; font-size: 0.9rem;">
              <div v-for="(val, key) in selected.specs" :key="key" style="display: flex; justify-content: space-between;">
                <span style="color: var(--muted);">{{ key }}：</span>
                <strong style="color: var(--ink-0);">{{ val }}</strong>
              </div>
            </div>
          </div>
        </div>

        <!-- 适用场景 -->
        <div style="margin-top: 1.5rem; background: var(--surface); padding: 1rem 1.25rem; border-radius: 8px; border: 1px dashed var(--stroke);">
          <strong style="color: var(--ink-0);">推荐适用场景：</strong>
          <span style="color: var(--muted); margin-left: 0.5rem;">{{ selected.scenarios }}</span>
        </div>
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
    title: 'WebRTC 实时音视频互动',
    description: '基于 WebRTC 协议栈与自研抗丢包算法，提供全球范围内低延迟音视频通信能力。',
    detail: '端到端延迟控制在 150ms 以内；支持 FEC 前向纠错与 NACK 重传；自适应码率调节 (BWE)；支持 Web / iOS / Android / Windows / macOS 多端 SDK 接入与集群级 SFU 架构。',
    specs: {
      '端到端时延': '80ms ~ 150ms',
      '支持协议': 'SRTP / ICE / STUN / TURN',
      '视频编解码': 'H.264 / AV1 / VP8 / VP9',
      '音频编解码': 'Opus (48kHz 全频带)',
      '抗丢包率': '网络丢包 30% 音频无损，视频流畅'
    },
    scenarios: '视频会议、在线互动教学、远程医疗问诊、应急指挥调度、游戏社交开黑'
  },
  {
    key: 'remote',
    title: 'Penclaw 远程桌面协同',
    description: '高性能屏幕捕获与自适应低开销输入控制，兼顾画质、流畅度与系统安全性。',
    detail: '支持 GPU 硬件加速抓屏与编码；智能 P2P 穿透与中继自动无缝倒换；全链路端到端加密防护；支持键盘鼠标剪贴板同步、文件快速双向拖拽传输及企业级审计日志追踪。',
    specs: {
      '画面帧率': '最高 60 FPS 超清传输',
      '输入延迟': '< 25ms 无感响应',
      '穿透技术': 'NAT-PMP / UPnP / 自研中继',
      '安全保障': 'TLS 1.3 + ChaCha20-Poly1305 加密',
      '系统支持': 'Windows 10/11, macOS, Linux, Android'
    },
    scenarios: 'IT 远程桌面运维、企业异地协同办公、售后软件调试、无人值守工控机巡检'
  },
  {
    key: 'danmaku',
    title: '海量高并发实时弹幕系统',
    description: '基于长连接分布式集群的高性能消息中枢，专为千万级高频互动直播场景定制。',
    detail: '基于分布式 Pub/Sub 架构；支持千万级客户端实时在线 WebSocket 长连保持；提供智能房间分流、动态流控与敏感词过滤；具备分布式消息回放、互动点赞送礼与弹幕冷热持久化。',
    specs: {
      '单机长连接': '100,000+ WebSocket 并发',
      '集群吞吐量': '10,000,000+ 消息/秒',
      '消息投递延迟': '< 30ms 实时推送',
      '持久化存储': 'Redis + 分布式时序存储',
      '高可用架构': '无状态节点水平弹性扩容'
    },
    scenarios: '赛事直播弹幕、大型在线发布会、在线课堂即时答题、万人同时互动聊天室'
  },
  {
    key: 'ai',
    title: 'AI 实时语音与交互解决方案',
    description: '打通多模态 AI 大模型与流式音视频通路，赋能拟人化智能交互新体验。',
    detail: '端到端流式 ASR 语音识别与 VAD 静音打断；接入私有化或公有大模型（LLM）进行知识库问答；结合超低延迟流式 TTS 合成与 3D 虚拟人面部驱动，实现真人般的即时对话。',
    specs: {
      '语音端到端响应': '< 800ms 首包音频返回',
      '打断响应时延': '< 180ms 毫秒级打断',
      '模型接入': '主流开源与商业 LLM 灵活适配',
      '知识库扩展': 'RAG 检索增强 + 工具调用 (Tools)',
      '部署方式': '支持私有化集群与云端混合部署'
    },
    scenarios: '智能政企客服、AI 外语口语陪练、数字人直播带货、智能座舱与智能硬件助理'
  }
]

const route = useRoute()
const selectedKey = ref(route.query.focus || solutions[0].key)
const selected = computed(() => solutions.find((s) => s.key === selectedKey.value) || solutions[0])

const onSelect = (item) => {
  selectedKey.value = item.key
}
</script>
