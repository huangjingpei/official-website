<script setup>
import { onMounted, ref } from 'vue'
import { getDownloads, resolveApiUrl } from '../services/api'

const downloads = ref([])

onMounted(async () => {
  try {
    const { data } = await getDownloads()
    downloads.value = data
  } catch (error) {
    downloads.value = [
      {
        id: 1,
        name: 'Penclaw 远程支持工具',
        version: 'v1.0.0',
        date: '2026-03-10',
        url: '/api/downloads/1/download'
      }
    ]
  }
})
</script>

<template>
  <section class="section">
    <div class="container">
      <h2>软件下载</h2>
      <div class="cards">
        <article v-for="item in downloads" :key="item.id" class="card">
          <h3>{{ item.name }}</h3>
          <p>版本：{{ item.version }}</p>
          <p>更新时间：{{ item.date }}</p>
          <a class="download-link" :href="resolveApiUrl(item.url)" download>立即下载</a>
        </article>
      </div>
    </div>
  </section>
</template>
