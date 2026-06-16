import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    proxy: {
      '/api/v1': {
        target: 'http://localhost:3001',
        changeOrigin: true
      },
      '/api/admin': {
        target: 'http://localhost:3001',
        changeOrigin: true
      },
      '/api/auth': {
        target: 'http://localhost:3001',
        changeOrigin: true
      }
    }
  }
})