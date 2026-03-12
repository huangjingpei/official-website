import axios from 'axios'

const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || '/api'

const api = axios.create({
  baseURL: apiBaseUrl,
  timeout: 8000
})

const AUTH_STORAGE_KEY = 'official_website_basic_auth'
const ROLE_STORAGE_KEY = 'official_website_role'

export const resolveApiUrl = (path) => {
  const origin = apiBaseUrl.replace(/\/api\/?$/, '')
  if (path.startsWith('http')) return path
  return `${origin}${path}`
}

export const setBasicAuth = (username, password) => {
  const token = btoa(`${username}:${password}`)
  localStorage.setItem(AUTH_STORAGE_KEY, token)
  window.dispatchEvent(new Event('auth-changed'))
}

export const clearAuth = () => {
  localStorage.removeItem(AUTH_STORAGE_KEY)
  localStorage.removeItem(ROLE_STORAGE_KEY)
  window.dispatchEvent(new Event('auth-changed'))
}

export const setRole = (role) => {
  localStorage.setItem(ROLE_STORAGE_KEY, role)
  window.dispatchEvent(new Event('auth-changed'))
}

export const getRole = () => localStorage.getItem(ROLE_STORAGE_KEY)

export const isAuthed = () => Boolean(localStorage.getItem(AUTH_STORAGE_KEY))

api.interceptors.request.use((config) => {
  const token = localStorage.getItem(AUTH_STORAGE_KEY)
  if (token) {
    config.headers = config.headers || {}
    config.headers.Authorization = `Basic ${token}`
  }
  return config
})

export const getNews = () => api.get('/news')
export const getDownloads = () => api.get('/downloads')
export const getDownloadDetail = (id) => api.get(`/downloads/${id}`)
export const downloadUrlFor = (id) => resolveApiUrl(`/api/downloads/${id}/download`)
export const submitContact = (payload) => api.post('/contacts', payload)
export const getAuthMe = () => api.get('/auth/me')
export const changePassword = (newPassword) => api.post('/auth/change-password', { newPassword })
export const uploadDownload = ({ name, version, file }) => {
  const form = new FormData()
  if (name) form.append('name', name)
  if (version) form.append('version', version)
  form.append('file', file)
  return api.post('/admin/downloads', form)
}

export default api
