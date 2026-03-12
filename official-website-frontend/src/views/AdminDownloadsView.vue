<script setup>
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import { clearAuth, getAuthMe, getDownloads, getRole, setRole, uploadDownload } from '../services/api'

const me = ref(null)
const loading = ref(false)
const errorMessage = ref('')
const downloads = ref([])
const role = ref(getRole())
const needsPasswordChange = ref(false)

const updateRole = () => {
  role.value = getRole()
}

const uploadForm = reactive({
  name: '',
  version: ''
})

const uploadFile = ref(null)

const isAdmin = computed(() => {
  return role.value === 'ADMIN'
})

const getSkipFlag = () => window.sessionStorage.getItem('admin_pw_change_skip') === '1'
const showNeedsPasswordBanner = computed(() => needsPasswordChange.value && !getSkipFlag())

const refreshMe = async () => {
  try {
    const { data } = await getAuthMe()
    me.value = data
    const roles = Array.isArray(data.roles) ? data.roles : []
    const nextRole = roles.includes('ROLE_ADMIN') ? 'ADMIN' : 'USER'
    role.value = nextRole
    setRole(nextRole)
    errorMessage.value = ''
    needsPasswordChange.value = Boolean(data.needsPasswordChange)
  } catch (error) {
    me.value = null
    role.value = getRole()
    errorMessage.value = ''
    needsPasswordChange.value = false
  }
}

const refreshDownloads = async () => {
  const { data } = await getDownloads()
  downloads.value = data
}

const onSkipPasswordPrompt = () => {
  window.sessionStorage.setItem('admin_pw_change_skip', '1')
  needsPasswordChange.value = false
}

const onLogout = async () => {
  clearAuth()
  window.sessionStorage.removeItem('admin_pw_change_skip')
  me.value = null
  role.value = null
  downloads.value = []
  needsPasswordChange.value = false
}

const onPickFile = (event) => {
  uploadFile.value = event.target.files?.[0] || null
}

const onUpload = async () => {
  if (!uploadFile.value) {
    errorMessage.value = '请选择要上传的软件文件。'
    return
  }
  loading.value = true
  try {
    await uploadDownload({
      name: uploadForm.name,
      version: uploadForm.version,
      file: uploadFile.value
    })
    uploadForm.name = ''
    uploadForm.version = ''
    uploadFile.value = null
    await refreshDownloads()
    errorMessage.value = ''
  } catch (error) {
    if (error?.response?.status === 401 || error?.response?.status === 403) {
      errorMessage.value = '权限不足或登录失效，请重新登录 administrator。'
    } else if (error?.response?.status === 413) {
      errorMessage.value = error?.response?.data?.message || '文件过大，请更换较小的文件或联系管理员调整上传限制。'
    } else {
      errorMessage.value = '上传失败，请稍后重试。'
    }
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  window.addEventListener('auth-changed', updateRole)
  await refreshMe()
  if (isAdmin.value) {
    await refreshDownloads()
  }
})

onUnmounted(() => {
  window.removeEventListener('auth-changed', updateRole)
})
</script>

<template>
  <div class="console-page">
    <div class="console-page-header">
      <div class="console-page-title">软件升级</div>
      <div class="meta">上传/维护软件下载版本</div>
    </div>

    <div v-if="errorMessage" class="console-alert console-alert-error">{{ errorMessage }}</div>

    <div v-if="!isAdmin" class="console-panel">
      <div class="console-panel-title">需要登录</div>
      <div class="meta">请先前往管理后台登录页完成登录。</div>
      <div class="console-actions">
        <RouterLink class="console-topbar-link" to="/console/login">前往登录</RouterLink>
      </div>
    </div>

    <div v-else class="console-grid">
      <div class="console-panel">
        <div class="console-panel-title">上传软件</div>
        <div v-if="showNeedsPasswordBanner" class="console-alert console-alert-warn" style="margin-bottom: 0.85rem">
          检测到你仍在使用初始密码，建议先去“修改密码”页面设置新密码。
          <RouterLink class="console-link-inline" to="/console/password">前往修改</RouterLink>
          <button class="console-link-btn" type="button" @click="onSkipPasswordPrompt">跳过</button>
        </div>

        <div class="console-form">
          <div class="console-field">
            <div class="console-label">软件名称</div>
            <input v-model="uploadForm.name" class="console-input" placeholder="可选" />
          </div>
          <div class="console-field">
            <div class="console-label">版本</div>
            <input v-model="uploadForm.version" class="console-input" placeholder="可选，如 v1.0.0" />
          </div>
          <div class="console-field" style="grid-column: 1 / -1">
            <div class="console-label">文件</div>
            <input type="file" @change="onPickFile" />
          </div>
          <div class="console-actions">
            <button class="console-btn console-btn-primary" :disabled="loading" type="button" @click="onUpload">上传</button>
            <button class="console-btn console-btn-danger" type="button" @click="onLogout">退出登录</button>
          </div>
        </div>
      </div>

      <div class="console-panel">
        <div class="console-panel-title">当前软件列表</div>
        <div v-if="downloads.length === 0" class="meta">暂无软件</div>
        <div v-else class="console-list">
          <div v-for="item in downloads" :key="item.id" class="console-list-item">
            <div class="console-list-title">{{ item.name }}</div>
            <div class="meta">版本：{{ item.version }}</div>
            <div class="meta">更新时间：{{ item.date }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
