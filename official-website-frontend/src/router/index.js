import { createRouter, createWebHistory } from 'vue-router'
import AboutView from '../views/AboutView.vue'
import AdminDownloadsView from '../views/AdminDownloadsView.vue'
import CompanyView from '../views/CompanyView.vue'
import DownloadsView from '../views/DownloadsView.vue'
import HomeView from '../views/HomeView.vue'
import NewsView from '../views/NewsView.vue'
import SolutionsView from '../views/SolutionsView.vue'
import ConsoleLayout from '../views/console/ConsoleLayout.vue'
import ConsoleLoginView from '../views/console/ConsoleLoginView.vue'
import ConsoleNewsView from '../views/console/ConsoleNewsView.vue'
import ConsolePasswordView from '../views/console/ConsolePasswordView.vue'
import ConsoleThemeView from '../views/console/ConsoleThemeView.vue'
import { clearAuth, getAuthMe, getRole, isAuthed, setRole } from '../services/api'

const routes = [
  { path: '/', name: 'home', component: HomeView },
  { path: '/company', name: 'company', component: CompanyView },
  { path: '/solutions', name: 'solutions', component: SolutionsView },
  { path: '/news', name: 'news', component: NewsView },
  { path: '/downloads', name: 'downloads', component: DownloadsView },
  { path: '/console/login', name: 'console-login', component: ConsoleLoginView },
  {
    path: '/console',
    component: ConsoleLayout,
    children: [
      { path: '', redirect: '/console/downloads' },
      { path: 'downloads', name: 'console-downloads', component: AdminDownloadsView },
      { path: 'news', name: 'console-news', component: ConsoleNewsView },
      { path: 'theme', name: 'console-theme', component: ConsoleThemeView },
      { path: 'password', name: 'console-password', component: ConsolePasswordView }
    ]
  },
  { path: '/admin', redirect: '/console/login' },
  { path: '/login', redirect: '/console/login' },
  { path: '/about', name: 'about', component: AboutView }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to) => {
  if (!to.path.startsWith('/console')) return true
  if (to.path === '/console/login') return true

  if (!isAuthed()) {
    return { path: '/console/login', query: { redirect: to.fullPath } }
  }

  if (getRole() === 'ADMIN') return true

  try {
    const { data } = await getAuthMe()
    const roles = Array.isArray(data.roles) ? data.roles : []
    const nextRole = roles.includes('ROLE_ADMIN') ? 'ADMIN' : 'USER'
    setRole(nextRole)
    if (nextRole !== 'ADMIN') {
      clearAuth()
      return { path: '/console/login', query: { redirect: to.fullPath } }
    }
    return true
  } catch (error) {
    clearAuth()
    return { path: '/console/login', query: { redirect: to.fullPath } }
  }
})

export default router
