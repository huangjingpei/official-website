import { createRouter, createWebHistory } from 'vue-router'
import AboutView from '../views/AboutView.vue'
import AdminDownloadsView from '../views/AdminDownloadsView.vue'
import CompanyView from '../views/CompanyView.vue'
import DownloadsView from '../views/DownloadsView.vue'
import HomeView from '../views/HomeView.vue'
import NewsView from '../views/NewsView.vue'
import NotFoundView from '../views/NotFoundView.vue'
import PrivacyView from '../views/PrivacyView.vue'
import SolutionsView from '../views/SolutionsView.vue'
import TermsView from '../views/TermsView.vue'
import ConsoleLayout from '../views/console/ConsoleLayout.vue'
import ConsoleLoginView from '../views/console/ConsoleLoginView.vue'
import ConsoleNewsView from '../views/console/ConsoleNewsView.vue'
import ConsoleContactsView from '../views/console/ConsoleContactsView.vue'
import ConsolePasswordView from '../views/console/ConsolePasswordView.vue'
import ConsoleThemeView from '../views/console/ConsoleThemeView.vue'
import { clearAuth, getAuthMe, getRole, isAuthed, setRole } from '../services/api'

const SITE_NAME = '杭州栩文科技 | graddu.com'

const routes = [
  { path: '/', name: 'home', component: HomeView, meta: { title: '首页 · ' + SITE_NAME } },
  { path: '/company', name: 'company', component: CompanyView, meta: { title: '公司概况 · ' + SITE_NAME } },
  { path: '/solutions', name: 'solutions', component: SolutionsView, meta: { title: '技术方案 · ' + SITE_NAME } },
  { path: '/news', name: 'news', component: NewsView, meta: { title: '实时要闻 · ' + SITE_NAME } },
  { path: '/downloads', name: 'downloads', component: DownloadsView, meta: { title: '软件下载 · ' + SITE_NAME } },
  { path: '/about', name: 'about', component: AboutView, meta: { title: '联系我们 · ' + SITE_NAME } },
  { path: '/privacy', name: 'privacy', component: PrivacyView, meta: { title: '隐私保护指引 · ' + SITE_NAME } },
  { path: '/terms', name: 'terms', component: TermsView, meta: { title: '用户服务协议 · ' + SITE_NAME } },
  { path: '/console/login', name: 'console-login', component: ConsoleLoginView, meta: { title: '管理员登录 · ' + SITE_NAME } },
  {
    path: '/console',
    component: ConsoleLayout,
    meta: { title: '管理后台 · ' + SITE_NAME },
    children: [
      { path: '', redirect: '/console/downloads' },
      { path: 'downloads', name: 'console-downloads', component: AdminDownloadsView, meta: { title: '软件升级 · 管理后台' } },
      { path: 'news', name: 'console-news', component: ConsoleNewsView, meta: { title: '实时要闻 · 管理后台' } },
      { path: 'theme', name: 'console-theme', component: ConsoleThemeView, meta: { title: '主题设置 · 管理后台' } },
      { path: 'password', name: 'console-password', component: ConsolePasswordView, meta: { title: '修改密码 · 管理后台' } },
      { path: 'contacts', name: 'console-contacts', component: ConsoleContactsView, meta: { title: '客户留言 · 管理后台' } }
    ]
  },
  { path: '/admin', redirect: '/console/login' },
  { path: '/login', redirect: '/console/login' },
  { path: '/:pathMatch(.*)*', name: 'not-found', component: NotFoundView, meta: { title: '页面不存在 · ' + SITE_NAME } }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) return savedPosition
    return { top: 0, behavior: 'smooth' }
  }
})

// Dynamic page title
router.afterEach((to) => {
  const title = to.meta?.title
  document.title = title || SITE_NAME
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
