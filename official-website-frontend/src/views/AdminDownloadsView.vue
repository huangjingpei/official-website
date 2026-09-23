<script setup>
import { onMounted, reactive, ref } from 'vue'
import { deleteDownload, getDownloads, uploadDownload } from '../services/api'

const loading = ref(false)
const errorMessage = ref('')
const downloads = ref([])

const PLATFORMS = [
  { value: '', label: '不限平台' },
  { value: 'windows', label: 'Windows' },
  { value: 'macos', label: 'macOS' },
  { value: 'linux', label: 'Linux' },
  { value: 'android', label: 'Android' },
  { value: 'ios', label: 'iOS' }
]

const uploadForm = reactive({ name: '', version: '', platform: '', sha256: '' })
const uploadFile = ref(null)

const refreshDownloads = async () => {
  try {
    const { data } = await getDownloads()
    downloads.value = data
  } catch {
    downloads.value = []
  }
}

const onPickFile = (event) => {
  uploadFile.value = event.target.files?.[0] || null
}

const onUpload = async () => {
  if (!uploadFile.value) { errorMessage.value = '请选择要上传的软件文件。'; return }
  loading.value = true
  errorMessage.value = ''
  try {
    await uploadDownload({
      name: uploadForm.name,
      version: uploadForm.version,
      platform: uploadForm.platform,
      sha256: uploadForm.sha256,
      file: uploadFile.value
    })
    uploadForm.name = ''
    uploadForm.version = ''
    uploadForm.platform = ''
    uploadForm.sha256 = ''
    uploadFile.value = null
    await refreshDownloads()
  } catch (error) {
    if (error?.response?.status === 401 || error?.response?.status === 403) {
      errorMessage.value = '权限不足或登录失效，请重新登录。'
    } else if (error?.response?.status === 413) {
      errorMessage.value = error?.response?.data?.message || '文件过大，请更换较小的文件或联系管理员调整上传限制。'
    } else {
      errorMessage.value = '上传失败，请稍后重试。'
    }
  } finally {
    loading.value = false
  }
}

const onDelete = async (item) => {
  if (!confirm(`确认删除「${item.name}」？文件将从服务器永久删除。`)) return
  try {
    await deleteDownload(item.id)
    await refreshDownloads()
  } catch {
    errorMessage.value = '删除失败，请稍后重试。'
  }
}

onMounted(refreshDownloads)
</script>

<template>
  <div class="console-page">
    <div class="console-page-header">
      <div class="console-page-title">软件升级</div>
      <div class="meta">上传/维护软件下载版本</div>
    </div>

    <div v-if="errorMessage" class="console-alert console-alert-error">{{ errorMessage }}</div>

    <div class="console-grid">
      <!-- 上传表单 -->
      <div class="console-panel">
        <div class="console-panel-title">上传软件包</div>
        <div class="console-form">
          <div class="console-field">
            <div class="console-label">软件名称</div>
            <input v-model="uploadForm.name" class="console-input" placeholder="如：Penclaw 远程工具" />
          </div>
          <div class="console-field">
            <div class="console-label">版本号</div>
            <input v-model="uploadForm.version" class="console-input" placeholder="如：v1.2.0" />
          </div>
          <div class="console-field">
            <div class="console-label">适用平台</div>
            <select v-model="uploadForm.platform" class="console-input">
              <option v-for="p in PLATFORMS" :key="p.value" :value="p.value">{{ p.label }}</option>
            </select>
          </div>
          <div class="console-field">
            <div class="console-label">SHA256 校验和 <span style="color:#94a3b8;font-weight:400;">（可选）</span></div>
            <input v-model="uploadForm.sha256" class="console-input" placeholder="文件 SHA256 哈希值" style="font-family:monospace;font-size:.85rem;" />
          </div>
          <div class="console-field" style="grid-column: 1 / -1">
            <div class="console-label">选择文件 <span style="color:#ef4444">*</span></div>
            <input type="file" @change="onPickFile" style="font-size:.9rem;" />
            <div v-if="uploadFile" style="margin-top:.4rem;font-size:.8rem;color:#64748b;">
              已选择：{{ uploadFile.name }}（{{ (uploadFile.size / 1024 / 1024).toFixed(1) }} MB）
            </div>
          </div>
          <div class="console-actions">
            <button class="console-btn console-btn-primary" :disabled="loading" type="button" @click="onUpload">
              {{ loading ? '上传中...' : '确认上传' }}
            </button>
          </div>
        </div>
      </div>

      <!-- 已发布列表 -->
      <div class="console-panel">
        <div class="console-panel-title">已发布文件列表</div>
        <div v-if="downloads.length === 0" class="meta" style="margin-top:.8rem;">暂无已发布软件。</div>
        <div v-else class="console-list">
          <div v-for="item in downloads" :key="item.id" class="console-list-item" style="display:flex;justify-content:space-between;align-items:flex-start;gap:.8rem;">
            <div style="min-width:0;flex:1;">
              <div class="console-list-title">{{ item.name }}</div>
              <div class="meta">版本：{{ item.version || '-' }}</div>
              <div class="meta">平台：{{ item.platform || '通用' }}</div>
              <div class="meta">更新：{{ item.date }}</div>
            </div>
            <button
              class="console-btn console-btn-danger"
              type="button"
              style="flex-shrink:0;font-size:.82rem;padding:.28rem .6rem;"
              @click="onDelete(item)"
            >删除</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
