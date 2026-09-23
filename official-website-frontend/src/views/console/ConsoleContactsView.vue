<script setup>
import { onMounted, ref } from 'vue'
import { getAdminContacts } from '../../services/api'

const contacts = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    const { data } = await getAdminContacts()
    contacts.value = data || []
  } catch (e) {
    contacts.value = []
  } finally {
    loading.value = false
  }
})

const exportCsv = () => {
  if (!contacts.value.length) return
  const headers = ['ID', '姓名/公司', '联系方式', '需求内容', '提交时间']
  const rows = contacts.value.map(c => [
    c.id,
    `"${(c.name || '').replace(/"/g, '""')}"`,
    `"${(c.contact || '').replace(/"/g, '""')}"`,
    `"${(c.message || '').replace(/"/g, '""')}"`,
    `"${c.createdAt || ''}"`
  ])
  const csv = [headers.join(','), ...rows.map(r => r.join(','))].join('\n')
  const blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `contacts_${new Date().toISOString().slice(0, 10)}.csv`
  a.click()
  URL.revokeObjectURL(url)
}
</script>

<template>
  <div>
    <!-- 工具栏 -->
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;">
      <span style="color:#64748b;font-size:.9rem;">
        共 <strong>{{ contacts.length }}</strong> 条留言
      </span>
      <button
        v-if="contacts.length"
        class="export-btn"
        type="button"
        @click="exportCsv"
      >
        ⬇ 导出 CSV
      </button>
    </div>

    <p v-if="loading" style="color:#64748b;">加载中...</p>
    <p v-else-if="contacts.length === 0" style="color:#64748b;">暂无客户意向留言。</p>

    <div v-else style="overflow-x:auto;">
      <table class="contacts-table">
        <thead>
          <tr>
            <th>姓名/公司</th>
            <th>联系方式</th>
            <th>需求内容</th>
            <th style="white-space:nowrap;">提交时间</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in contacts" :key="item.id">
            <td style="font-weight:600;white-space:nowrap;">{{ item.name }}</td>
            <td style="white-space:nowrap;">{{ item.contact }}</td>
            <td style="max-width:380px;word-break:break-all;">{{ item.message }}</td>
            <td style="white-space:nowrap;color:#64748b;font-size:.85rem;">{{ item.createdAt }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped>
.export-btn {
  background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px;
  padding: .35rem .9rem; font-size: .85rem; cursor: pointer; color: #1e293b;
  font-weight: 600;
}
.export-btn:hover { background: #e2e8f0; }

.contacts-table {
  width: 100%; border-collapse: collapse; font-size: .92rem;
}
.contacts-table th {
  padding: .6rem .9rem; text-align: left;
  border-bottom: 2px solid #e2e8f0; color: #475569; font-size: .85rem;
}
.contacts-table td {
  padding: .65rem .9rem; border-bottom: 1px solid #f1f5f9; vertical-align: top;
}
.contacts-table tr:hover td { background: #f8fafc; }
</style>
