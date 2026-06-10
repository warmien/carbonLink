import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi } from '../api/auth'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string>(localStorage.getItem('admin_token') || '')
  const username = ref<string>(localStorage.getItem('admin_username') || '')
  const role = ref<string>(localStorage.getItem('admin_role') || '')

  const isAuthenticated = computed(() => !!token.value)
  const isSuperAdmin = computed(() => role.value === 'SUPER_ADMIN')
  const isOperator = computed(() => role.value === 'OPERATOR' || role.value === 'SUPER_ADMIN')

  async function login(user: string, password: string): Promise<void> {
    const res = await authApi.login(user, password)
    token.value = res.token
    username.value = user
    role.value = res.role || ''
    localStorage.setItem('admin_token', res.token)
    localStorage.setItem('admin_username', user)
    localStorage.setItem('admin_role', res.role || '')
  }

  function logout(): void {
    token.value = ''
    username.value = ''
    role.value = ''
    localStorage.removeItem('admin_token')
    localStorage.removeItem('admin_username')
    localStorage.removeItem('admin_role')
  }

  return { token, username, role, isAuthenticated, isSuperAdmin, isOperator, login, logout }
})