<template>
  <div class="app-shell">
    <SiteHeader v-if="!isConsole" />
    <main class="main-content">
      <router-view />
    </main>
    <SiteFooter v-if="!isConsole" />
    <SiteFloatWidget v-if="!isConsole" />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import SiteFooter from './components/SiteFooter.vue'
import SiteHeader from './components/SiteHeader.vue'
import SiteFloatWidget from './components/SiteFloatWidget.vue'

const route = useRoute()
const isConsole = computed(() => route.path.startsWith('/console'))
</script>
