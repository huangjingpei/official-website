<script setup>
import { onMounted, ref, reactive } from 'vue'
import { adminGetNews, adminCreateNews, adminUpdateNews, adminDeleteNews } from '../../services/api'

const newsList = ref([])
const loading = ref(true)
const saving = ref(false)
const toast = ref('')
let toastTimer = null

const showForm = ref(false)
const editId = ref(null)
const form = reactive({ title: '', summary: '', content: '', published: true })

async function load() {
  loading.value = true
  try {
    const { data } = await adminGetNews()
    newsList.value = data || []
  } catch {
    newsList.value = []
  } finally {
    loading.value = false
  }
}

function openCreate() {
  editId.value = null
  form.title = ''
  form.summary = ''
  form.content = ''
  form.published = true
  showForm.value = true
}

function openEdit(item) {
  editId.value = item.id
  form.title = item.title
  form.summary = item.summary || ''
  form.content = item.content || ''
  form.published = item.published !== false
  showForm.value = true
}

function cancelForm() {
  showForm.value = false
}

async function save() {
  if (!form.title.trim()) { notify('标题不能为空'); return }
  saving.value = true
  try {
    const payload = { title: form.title, summary: form.summary, content: form.content, published: form.published }
    if (editId.value) {
      await adminUpdateNews(editId.value, payload)
      notify('更新成功')
    } else {
      await adminCreateNews(payload)
      notify('发布成功')
    }
    showForm.value = false
    await load()
  } catch {
    notify('保存失败，请重试')
  } finally {
    saving.value = false
  }
}

async function remove(item) {
  if (!confirm(`确认删除「${item.title}」？`)) return
  try {
    await adminDeleteNews(item.id)
    notify('已删除')
    await load()
  } catch {
    notify('删除失败')
  }
}

async function togglePublish(item) {
  try {
    await adminUpdateNews(item.id, {
      title: item.title,
      summary: item.summary || '',
      content: item.content || '',
      published: !item.published
    })
    notify(item.published ? '已下架' : '已上架')
    await load()
  } catch {
    notify('操作失败')
  }
}

function notify(msg) {
  toast.value = msg
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => { toast.value = '' }, 2800)
}

onMounted(load)
</script>

<template>
  <div>
    <!-- Toast -->
    <transition name="toast">
      <div v-if="toast" class="cn-toast">{{ toast }}</div>
    </transition>

    <!-- Toolbar -->
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1rem;">
      <span style="color:var(--muted); font-size:0.9rem;">共 {{ newsList.length }} 条新闻</span>
      <button class="btn-primary" @click="openCreate">+ 新增新闻</button>
    </div>

    <!-- Loading -->
    <p v-if="loading" style="color:var(--muted);">加载中...</p>
    <p v-else-if="newsList.length === 0" style="color:var(--muted);">暂无新闻，请点击上方「新增新闻」发布。</p>

    <!-- News List -->
    <div v-else class="cn-list">
      <div v-for="item in newsList" :key="item.id" class="cn-card">
        <div class="cn-card-header">
          <span class="cn-badge" :class="item.published ? 'badge-pub' : 'badge-draft'">
            {{ item.published ? '已发布' : '草稿' }}
          </span>
          <span class="cn-date">{{ item.date }}</span>
        </div>
        <div class="cn-title">{{ item.title }}</div>
        <div v-if="item.summary" class="cn-summary">{{ item.summary }}</div>
        <div class="cn-actions">
          <button class="btn-sm" @click="openEdit(item)">编辑</button>
          <button class="btn-sm btn-warn" @click="togglePublish(item)">
            {{ item.published ? '下架' : '上架' }}
          </button>
          <button class="btn-sm btn-danger" @click="remove(item)">删除</button>
        </div>
      </div>
    </div>

    <!-- Form Modal -->
    <div v-if="showForm" class="cn-overlay" @click.self="cancelForm">
      <div class="cn-modal">
        <h3 style="margin:0 0 1.2rem;">{{ editId ? '编辑新闻' : '新增新闻' }}</h3>
        <label class="cn-label">标题 <span style="color:#ef4444">*</span></label>
        <input v-model="form.title" class="cn-input" placeholder="新闻标题" maxlength="300" />

        <label class="cn-label">摘要（列表展示用）</label>
        <textarea v-model="form.summary" class="cn-input" rows="2" placeholder="一句话描述，不超过200字" maxlength="1000" />

        <label class="cn-label">正文内容</label>
        <textarea v-model="form.content" class="cn-input" rows="8" placeholder="支持纯文本，后续将支持Markdown..." />

        <label class="cn-label" style="display:flex; align-items:center; gap:.5rem; cursor:pointer;">
          <input type="checkbox" v-model="form.published" style="width:16px; height:16px;" />
          立即发布（不勾选则保存为草稿）
        </label>

        <div style="display:flex; gap:.8rem; margin-top:1.2rem; justify-content:flex-end;">
          <button class="btn-sm" @click="cancelForm">取消</button>
          <button class="btn-primary" :disabled="saving" @click="save">
            {{ saving ? '保存中...' : (editId ? '更新' : '发布') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.cn-toast {
  position: fixed; top: 1.5rem; right: 1.5rem; z-index: 9999;
  background: #1e293b; color: #f8fafc; padding: .7rem 1.4rem;
  border-radius: 8px; font-size: .9rem; box-shadow: 0 4px 16px rgba(0,0,0,.3);
}
.toast-enter-active, .toast-leave-active { transition: opacity .3s; }
.toast-enter-from, .toast-leave-to { opacity: 0; }

.btn-primary {
  background: var(--accent, #2563eb); color: #fff;
  border: none; border-radius: 6px; padding: .5rem 1.1rem;
  font-size: .9rem; cursor: pointer; font-weight: 600;
}
.btn-primary:disabled { opacity: .6; cursor: not-allowed; }
.btn-sm {
  background: #f1f5f9; color: #334155;
  border: 1px solid #e2e8f0; border-radius: 5px;
  padding: .3rem .8rem; font-size: .85rem; cursor: pointer;
}
.btn-warn { background: #fff7ed; color: #c2410c; border-color: #fed7aa; }
.btn-danger { background: #fef2f2; color: #dc2626; border-color: #fecaca; }

.cn-list { display: flex; flex-direction: column; gap: .8rem; }
.cn-card {
  background: #fff; border: 1px solid #e2e8f0; border-radius: 10px; padding: 1rem 1.2rem;
}
.cn-card-header { display: flex; align-items: center; gap: .7rem; margin-bottom: .4rem; }
.cn-badge { font-size: .75rem; font-weight: 700; border-radius: 20px; padding: .15rem .6rem; }
.badge-pub { background: #dcfce7; color: #16a34a; }
.badge-draft { background: #f1f5f9; color: #64748b; }
.cn-date { font-size: .8rem; color: #94a3b8; }
.cn-title { font-size: 1rem; font-weight: 700; color: #1e293b; margin-bottom: .3rem; }
.cn-summary { font-size: .875rem; color: #475569; margin-bottom: .6rem; }
.cn-actions { display: flex; gap: .5rem; }

.cn-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,.45);
  display: flex; align-items: center; justify-content: center; z-index: 1000;
}
.cn-modal {
  background: #fff; border-radius: 14px; padding: 2rem;
  width: min(560px, 95vw); max-height: 90vh; overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0,0,0,.25);
}
.cn-label { display: block; font-size: .85rem; font-weight: 600; color: #475569; margin: .8rem 0 .3rem; }
.cn-input {
  width: 100%; box-sizing: border-box;
  border: 1px solid #e2e8f0; border-radius: 7px;
  padding: .55rem .8rem; font-size: .95rem; font-family: inherit;
  outline: none; resize: vertical;
}
.cn-input:focus { border-color: var(--accent, #2563eb); }
</style>
