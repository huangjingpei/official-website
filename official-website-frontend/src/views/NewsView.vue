<script setup>
import { onMounted, ref } from 'vue'
import { getNews } from '../services/api'

const newsList = ref([])

onMounted(async () => {
  try {
    const { data } = await getNews()
    newsList.value = data
  } catch (error) {
    newsList.value = [
      { id: 1, title: '官网第一版发布', summary: '已上线公司概况与核心技术模块。', date: '2026-03-10' }
    ]
  }
})
</script>

<template>
  <section class="section">
    <div class="container">
      <h2>实时要闻</h2>
      <div class="cards">
        <article v-for="item in newsList" :key="item.id" class="card">
          <h3>{{ item.title }}</h3>
          <p>{{ item.summary }}</p>
          <p class="meta">{{ item.date }}</p>
        </article>
      </div>
    </div>
  </section>
</template>
