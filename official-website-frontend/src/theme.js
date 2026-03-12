export const THEMES = ['business', 'cute']

const normalizeTheme = (value) => {
  if (typeof value !== 'string') return null
  const next = value.trim().toLowerCase()
  return THEMES.includes(next) ? next : null
}

export const getTheme = () => {
  return normalizeTheme(window.localStorage.getItem('ui-theme')) || null
}

export const setTheme = (theme) => {
  const next = normalizeTheme(theme)
  if (!next) return
  document.documentElement.setAttribute('data-theme', next)
  window.localStorage.setItem('ui-theme', next)
}

export const initTheme = () => {
  const urlTheme = normalizeTheme(new URLSearchParams(window.location.search).get('theme'))
  if (urlTheme) {
    setTheme(urlTheme)
    return
  }

  const stored = getTheme()
  if (stored) {
    document.documentElement.setAttribute('data-theme', stored)
    return
  }

  const envTheme = normalizeTheme(import.meta.env.VITE_UI_THEME)
  document.documentElement.setAttribute('data-theme', envTheme || 'business')
}
