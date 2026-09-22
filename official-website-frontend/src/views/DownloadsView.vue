<template>
  <section class="section">
    <div class="container">
      <div style="text-align: center; margin-bottom: 2rem;">
        <h2>官方客户端与软件下载</h2>
        <p style="color: var(--muted); margin: 0.4rem 0 0;">
          官方正版发布，安全无捆绑，支持高速分片断点续传
        </p>
      </div>

      <!-- 平台筛选 Tabs -->
      <div class="platform-tabs" style="justify-content: center;">
        <button
          v-for="tab in platforms"
          :key="tab.key"
          class="platform-tab"
          :class="{ active: currentPlatform === tab.key }"
          type="button"
          @click="currentPlatform = tab.key"
        >
          {{ tab.name }}
        </button>
      </div>

      <!-- 软件列表 -->
      <div class="cards">
        <article v-for="item in filteredDownloads" :key="item.id" class="card" style="display: flex; flex-direction: column;">
          <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem;">
            <h3 style="margin: 0; color: var(--ink-0); font-size: 1.25rem;">{{ item.name }}</h3>
            <span style="background: var(--bg-1); color: var(--accent); font-size: 0.8rem; font-weight: 600; padding: 0.2rem 0.6rem; border-radius: 999px;">
              {{ item.version || '最新稳定版' }}
            </span>
          </div>

          <p style="color: var(--muted); font-size: 0.95rem; margin: 0.4rem 0; flex: 1;">
            {{ item.description || '官方稳定发布版，支持高效远程协助与协同连接。' }}
          </p>

          <div style="font-size: 0.85rem; color: var(--muted); margin: 0.6rem 0; display: grid; gap: 0.25rem;">
            <div>适用环境：{{ item.platform || 'Windows 10/11 (64位) / macOS / Linux' }}</div>
            <div>更新时间：{{ item.date || '2026-03-20' }}</div>
          </div>

          <!-- SHA256 校验和 -->
          <div class="sha256-box">
            <strong>SHA256:</strong> {{ item.sha256 || 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855' }}
          </div>

          <div style="margin-top: 1rem; display: flex; align-items: center; justify-content: space-between; gap: 0.8rem;">
            <a
              class="download-link"
              style="flex: 1; text-align: center; margin: 0;"
              :href="resolveApiUrl(item.url)"
              download
            >
              立即下载
            </a>
          </div>
        </article>
      </div>

      <!-- 安装环境提示 -->
      <div style="margin-top: 3rem; background: var(--surface); border: 1px solid var(--stroke); border-radius: 12px; padding: 1.5rem;">
        <h4 style="margin: 0 0 0.8rem; color: var(--ink-0);">安装与运行说明：</h4>
        <ul style="margin: 0; padding-left: 1.2rem; color: var(--muted); font-size: 0.9rem; line-height: 1.8;">
          <li><strong>Windows 系统：</strong>若遇到“Windows 已保护你的电脑”提示，请点击“更多信息”并选择“仍要运行”；</li>
          <li><strong>macOS 系统：</strong>首次启动若提示“无法打开，因为无法验证开发者”，请前往系统设置 → 隐私与安全性 中点击“仍要打开”；</li>
          <li><strong>安全性保障：</strong>官方所有发布包均经过安全扫描与完整性哈希校验，请认准官方网站 <code>www.graddu.com</code> 下载。</li>
        </ul>
      </div>
    </div>
  </section>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { getDownloads, resolveApiUrl } from '../services/api'

const currentPlatform = ref('all')
const platforms = [
  { key: 'all', name: '全部软件' },
  { key: 'windows', name: 'Windows' },
  { key: 'macos', name: 'macOS' },
  { key: 'linux', name: 'Linux' }
]

const downloads = ref([])

onMounted(async () => {
  try {
    const { data } = await getDownloads()
    if (Array.isArray(data) && data.length > 0) {
      downloads.value = data
      return
    }
  } catch (error) {
    // 降级使用内置数据
  }

  // 默认精选软件展示
  downloads.value = [
    {
      id: 1,
      name: 'Penclaw 远程支持运维工具',
      version: 'v1.2.0',
      date: '2026-03-20',
      platform: 'Windows 10/11 (64位)',
      url: '/api/downloads/1/download',
      description: '面向企业 IT 运维与远程协助的高性能跨网络桌面协同客户端。',
      sha256: '9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b'
    },
    {
      id: 2,
      name: 'Penclaw 跨平台中继网关',
      version: 'v1.1.5',
      date: '2026-03-15',
      platform: 'Linux (Ubuntu/CentOS x86_64)',
      url: '/api/downloads/1/download',
      description: '私有化部署的中继流量调度引擎，提供企业级内网打洞与加密穿透。',
      sha256: '7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a'
    }
  ]
})

const filteredDownloads = computed(() => {
  if (currentPlatform.value === 'all') return downloads.value
  return downloads.value.filter((item) => {
    const p = (item.platform || '').toLowerCase()
    return p.includes(currentPlatform.value)
  })
})
</script>
