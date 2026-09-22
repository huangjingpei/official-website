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
</script>

<template>
  <div>
    <p v-if="loading" style="color: var(--muted);">加载中...</p>
    <p v-else-if="contacts.length === 0" style="color: var(--muted);">暂无客户意向留言。</p>
    <table v-else class="console-table" style="width: 100%; border-collapse: collapse; font-size: 0.95rem;">
      <thead>
        <tr style="border-bottom: 2px solid #e2e8f0; text-align: left;">
          <th style="padding: 0.6rem 0.8rem;">姓名/公司</th>
          <th style="padding: 0.6rem 0.8rem;">联系方式</th>
          <th style="padding: 0.6rem 0.8rem;">需求内容</th>
          <th style="padding: 0.6rem 0.8rem; white-space: nowrap;">提交时间</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in contacts" :key="item.id" style="border-bottom: 1px solid #f1f5f9;">
          <td style="padding: 0.6rem 0.8rem; font-weight: 600;">{{ item.name }}</td>
          <td style="padding: 0.6rem 0.8rem;">{{ item.contact }}</td>
          <td style="padding: 0.6rem 0.8rem; max-width: 360px; word-break: break-all;">{{ item.message }}</td>
          <td style="padding: 0.6rem 0.8rem; white-space: nowrap; color: #64748b;">{{ item.createdAt }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
