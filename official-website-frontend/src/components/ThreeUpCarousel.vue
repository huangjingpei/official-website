<script setup>
import { nextTick, onMounted, onUnmounted, ref, watch } from 'vue'

const props = defineProps({
  items: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['select'])

const viewportRef = ref(null)
const pageCount = ref(1)
const currentPage = ref(0)
const isDragging = ref(false)

const clamp = (value, min, max) => Math.min(Math.max(value, min), max)

const getGap = (track) => {
  const styles = getComputedStyle(track)
  const gapValue = styles.gap || styles.columnGap || '0px'
  return Number.parseFloat(gapValue) || 0
}

const getStep = () => {
  const viewport = viewportRef.value
  if (!viewport) return 0
  const track = viewport.querySelector('.carousel-track')
  const slide = viewport.querySelector('.carousel-slide')
  if (!track || !slide) return viewport.clientWidth
  const gap = getGap(track)
  return slide.getBoundingClientRect().width + gap
}

const getVisibleCount = () => {
  const viewport = viewportRef.value
  if (!viewport) return 1
  const track = viewport.querySelector('.carousel-track')
  const slide = viewport.querySelector('.carousel-slide')
  if (!track || !slide) return 1
  const gap = getGap(track)
  const slideWidth = slide.getBoundingClientRect().width
  const viewportWidth = viewport.clientWidth
  const max = props.items.length || 1
  let fit = 1
  for (let i = 1; i <= max; i += 1) {
    const total = i * slideWidth + (i - 1) * gap
    if (total <= viewportWidth + 1) {
      fit = i
    }
  }
  return clamp(fit, 1, max)
}

const recomputePagination = () => {
  const visible = getVisibleCount()
  const maxIndex = Math.max((props.items.length || 1) - visible, 0)
  pageCount.value = maxIndex + 1
  currentPage.value = clamp(currentPage.value, 0, pageCount.value - 1)
}

const scrollToPage = (page) => {
  const el = viewportRef.value
  if (!el) return
  recomputePagination()
  const target = clamp(page, 0, pageCount.value - 1)
  currentPage.value = target
  const step = getStep()
  el.scrollTo({ left: step * target, behavior: 'smooth' })
}

let resizeRaf = 0
const scheduleRecompute = () => {
  if (resizeRaf) {
    cancelAnimationFrame(resizeRaf)
  }
  resizeRaf = requestAnimationFrame(() => {
    resizeRaf = 0
    recomputePagination()
    onScroll()
  })
}

const onScroll = () => {
  const el = viewportRef.value
  if (!el) return
  const step = getStep()
  if (!step) return
  recomputePagination()
  currentPage.value = clamp(Math.round(el.scrollLeft / step), 0, pageCount.value - 1)
}

const scrollToRelative = (delta) => {
  recomputePagination()
  scrollToPage(clamp(currentPage.value + delta, 0, pageCount.value - 1))
}

const onKeydown = (event) => {
  if (event.key === 'ArrowLeft') {
    event.preventDefault()
    scrollToRelative(-1)
  } else if (event.key === 'ArrowRight') {
    event.preventDefault()
    scrollToRelative(1)
  } else if (event.key === 'Home') {
    event.preventDefault()
    scrollToPage(0)
  } else if (event.key === 'End') {
    event.preventDefault()
    scrollToPage(pageCount.value - 1)
  }
}

const onWheel = (event) => {
  const el = viewportRef.value
  if (!el) return
  if (el.scrollWidth <= el.clientWidth + 1) return
  if (Math.abs(event.deltaY) <= Math.abs(event.deltaX)) return
  event.preventDefault()
  el.scrollBy({ left: event.deltaY, behavior: 'auto' })
  scheduleRecompute()
}

let pointerDown = false
let pointerStartX = 0
let pointerStartY = 0
let pointerStartScrollLeft = 0
let pointerMoved = false
let lastDragAt = 0
const dragThreshold = 7

const onPointerDown = (event) => {
  const el = viewportRef.value
  if (!el) return
  if (event.pointerType === 'touch') return
  if (event.button !== 0) return
  pointerDown = true
  pointerMoved = false
  pointerStartX = event.clientX
  pointerStartY = event.clientY
  pointerStartScrollLeft = el.scrollLeft
  isDragging.value = false
  el.setPointerCapture(event.pointerId)
}

const onPointerMove = (event) => {
  const el = viewportRef.value
  if (!el) return
  if (!pointerDown) return
  const dx = event.clientX - pointerStartX
  const dy = event.clientY - pointerStartY
  if (!pointerMoved && Math.hypot(dx, dy) > dragThreshold) {
    pointerMoved = true
    isDragging.value = true
  }
  if (!pointerMoved) return
  event.preventDefault()
  el.scrollLeft = pointerStartScrollLeft - dx
  scheduleRecompute()
}

const onPointerUp = () => {
  if (!pointerDown) return
  pointerDown = false
  if (pointerMoved) {
    lastDragAt = Date.now()
  }
  pointerMoved = false
  isDragging.value = false
}

const onCardClick = (item, event) => {
  if (Date.now() - lastDragAt < 250) {
    event.preventDefault()
    event.stopPropagation()
    return
  }
  emit('select', item)
}

onMounted(async () => {
  await nextTick()
  scheduleRecompute()
  window.addEventListener('resize', scheduleRecompute)
})

onUnmounted(() => {
  window.removeEventListener('resize', scheduleRecompute)
  if (resizeRaf) {
    cancelAnimationFrame(resizeRaf)
  }
})

watch(
  () => props.items.length,
  async () => {
    await nextTick()
    scheduleRecompute()
  }
)
</script>

<template>
  <div class="carousel-shell">
    <div
      ref="viewportRef"
      class="carousel-viewport"
      :class="{ dragging: isDragging }"
      tabindex="0"
      @scroll="onScroll"
      @keydown="onKeydown"
      @wheel="onWheel"
      @pointerdown="onPointerDown"
      @pointermove="onPointerMove"
      @pointerup="onPointerUp"
      @pointercancel="onPointerUp"
    >
      <div class="carousel-track">
        <article v-for="item in items" :key="item.title" class="card carousel-slide" @click="onCardClick(item, $event)">
          <h3>{{ item.title }}</h3>
          <p class="meta">{{ item.description }}</p>
        </article>
      </div>
    </div>

    <div class="carousel-pagination" role="tablist" aria-label="轮播分页">
      <button
        v-for="index in pageCount"
        :key="index"
        class="carousel-dot"
        type="button"
        :class="{ active: currentPage === index - 1 }"
        :aria-label="`第 ${index} 页`"
        :aria-selected="currentPage === index - 1"
        role="tab"
        @click="scrollToPage(index - 1)"
      />
    </div>
  </div>
</template>
