import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('../views/LoginPage.vue')
    },
    {
      path: '/',
      component: () => import('../layouts/AdminLayout.vue'),
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          name: 'Dashboard',
          component: () => import('../views/DashboardPage.vue')
        },
        {
          path: 'user',
          name: 'UserAnalytics',
          component: () => import('../views/UserAnalyticsPage.vue')
        },
        {
          path: 'product',
          name: 'ProductAnalytics',
          component: () => import('../views/ProductAnalyticsPage.vue')
        },
        {
          path: 'carbon',
          name: 'CarbonAnalytics',
          component: () => import('../views/CarbonAnalyticsPage.vue')
        }
      ]
    }
  ]
})

router.beforeEach((to, _from, next) => {
  const authStore = useAuthStore()
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else if (to.path === '/login' && authStore.isAuthenticated) {
    next('/')
  } else {
    next()
  }
})

export default router