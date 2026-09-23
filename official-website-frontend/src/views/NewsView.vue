<script setup>
import { onMounted, ref } from 'vue'
import { getNews, getNewsDetail } from '../services/api'

const newsList = ref([])
const loading = ref(true)
const selected = ref(null)
const detailLoading = ref(false)

onMounted(async () => {
  try {
    const { data } = await getNews()
    newsList.value = data || []
  } catch {
    newsList.value = [
      { id: 1, title: '官网正式上线', summary: '官网已上线公司概况与核心技术模块。', date: '2026-03-10' }
    ]
  } finally {
    loading.value = false
  }
})

const openDetail = async (item) => {
  selected.value = { ...item, content: item.content || '' }
  if (!item.content) {
    detailLoading.value = true
    try {
      const { data } = await getNewsDetail(item.id)
      selected.value = data
    } catch {
      // keep summary
    } finally {
      detailLoading.value = false
    }
  }
}

const closeDetail = () => { selected.value = null }
</script>

<template>
  <section class="section">
    <div class="container">
      <div style="text-align:center;margin-bottom:2rem;">
        <h2>实时要闻</h2>
        <p style="color:var(--muted);margin:.4rem 0 0;">栩文科技最新动态与技术发版公告</p>
      </div>

      <!-- 骨架加载 -->
      <div v-if="loading" class="cards">
        <div v-for="i in 3" :key="i" class="card news-skeleton">
          <div class="sk-line sk-title"></div>
          <div class="sk-line sk-body"></div>
          <div class="sk-line sk-date"></div>
        </div>
      </div>

      <!-- 空状态 -->
      <div v-else-if="newsList.length === 0" style="text-align:center;padding:4rem 1rem;color:var(--muted);">
        <div style="font-size:3rem;margin-bottom:.8rem;">📰</div>
        <p>暂无新闻公告，敬请期待。</p>
      </div>

      <!-- 新闻卡片列表 -->
      <div v-else class="cards">
        <article
          v-for="item in newsList"
          :key="item.id"
          class="card news-card"
          @click="openDetail(item)"
          style="cursor:pointer;"
        >
          <div class="news-meta-row">
            <span class="news-date">{{ item.date }}</span>
            <span class="news-read-more">查看详情 →</span>
          </div>
          <h3 style="margin:.5rem 0 .6rem;color:var(--ink-0);font-size:1.15rem;line-height:1.4;">{{ item.title }}</h3>
          <p style="color:var(--muted);font-size:.95rem;line-height:1.7;margin:0;">{{ item.summary }}</p>
        </article>
      </div>
    </div>
  </section>

  <!-- 详情弹窗 -->
  <transition name="modal">
    <div v-if="selected" class="news-overlay" @click.self="closeDetail">
      <div class="news-modal">
        <button class="news-modal-close" type="button" @click="closeDetail" aria-label="关闭">×</button>
        <div class="news-modal-date">{{ selected.date }}</div>
        <h2 class="news-modal-title">{{ selected.title }}</h2>
        <hr style="border:none;border-top:1px solid var(--stroke);margin:1.2rem 0;" />
        <div v-if="detailLoading" style="color:var(--muted);text-align:center;padding:2rem;">加载中...</div>
        <div v-else class="news-modal-body">
          <p v-if="selected.content">{{ selected.content }}</p>
          <p v-else style="color:var(--muted);">{{ selected.summary }}</p>
        </div>
      </div>
    </div>
  </transition>
</template>

<style scoped>
.news-card { transition: transform .18s, box-shadow .18s; }
.news-card:hover { transform: translateY(-3px); box-shadow: 0 8px 28px rgba(0,0,0,.12); }

.news-meta-row {
  display: flex; justify-content: space-between; align-items: center;
  font-size: .85rem;
}
.news-date { color: var(--muted); }
.news-read-more { color: var(--accent); font-weight: 600; font-size: .82rem; }

/* Skeleton */
.news-skeleton { pointer-events: none; }
.sk-line {
  background: linear-gradient(90deg, var(--stroke) 25%, rgba(255,255,255,.18) 50%, var(--stroke) 75%);
  background-size: 200% 100%;
  animation: shimmer 1.4s infinite;
  border-radius: 6px;
  margin-bottom: .6rem;
}
.sk-title  { height: 22px; width: 70%; }
.sk-body   { height: 16px; width: 100%; }
.sk-date   { height: 13px; width: 30%; }
@keyframes shimmer { from { background-position: 200% 0; } to { background-position: -200% 0; } }

/* Modal */
.news-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,.5);
  display: flex; align-items: center; justify-content: center; z-index: 1000;
  padding: 1rem;
}
.news-modal {
  background: var(--surface-strong, #fff); border-radius: 16px;
  padding: 2rem 2.2rem; width: min(680px, 100%); max-height: 88vh; overflow-y: auto;
  box-shadow: 0 24px 64px rgba(0,0,0,.28); position: relative;
}
.news-modal-close {
  position: absolute; top: 1rem; right: 1.2rem;
  background: none; border: none; font-size: 1.6rem; cursor: pointer; color: var(--muted);
  line-height: 1;
}
.news-modal-date { color: var(--muted); font-size: .85rem; margin-bottom: .4rem; }
.news-modal-title { font-size: 1.5rem; font-weight: 800; color: var(--ink-0); margin: 0; }
.news-modal-body { color: var(--ink-1); line-height: 1.85; font-size: .97rem; white-space: pre-wrap; }

.modal-enter-active, .modal-leave-active { transition: opacity .25s; }
.modal-enter-from, .modal-leave-to { opacity: 0; }
</style>
