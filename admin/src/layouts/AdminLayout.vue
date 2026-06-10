<template>
  <el-container class="admin-layout">
    <el-aside width="220px" class="admin-aside">
      <div class="admin-logo">
        <h2>碳易链</h2>
        <span>管理后台</span>
      </div>
      <el-menu :default-active="currentRoute" router class="admin-menu">
        <el-menu-item index="/">
          <el-icon><DataLine /></el-icon>
          <span>数据概览</span>
        </el-menu-item>
        <el-menu-item index="/user">
          <el-icon><User /></el-icon>
          <span>用户分析</span>
        </el-menu-item>
        <el-menu-item index="/product">
          <el-icon><Goods /></el-icon>
          <span>商品分析</span>
        </el-menu-item>
        <el-menu-item index="/carbon">
          <el-icon><Sunny /></el-icon>
          <span>碳减排分析</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header class="admin-header">
        <div class="header-left">
          <span class="page-title">{{ pageTitle }}</span>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <span class="admin-user">
              <el-icon><UserFilled /></el-icon>
              {{ authStore.username }}
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main class="admin-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { DataLine, User, Goods, Sunny, UserFilled } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const currentRoute = computed(() => route.path)

const pageTitleMap: Record<string, string> = {
  '/': '数据概览',
  '/user': '用户分析',
  '/product': '商品分析',
  '/carbon': '碳减排分析'
}

const pageTitle = computed(() => pageTitleMap[route.path] || '数据概览')

function handleCommand(command: string): void {
  if (command === 'logout') {
    authStore.logout()
    router.push('/login')
  }
}
</script>

<style scoped>
.admin-layout { height: 100vh; }
.admin-aside {
  background: #001529;
  overflow: hidden;
}
.admin-logo {
  height: 64px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #fff;
}
.admin-logo h2 { margin: 0; font-size: 20px; }
.admin-logo span { font-size: 12px; opacity: 0.7; }
.admin-menu {
  border-right: none;
  background: #001529;
}
.admin-menu .el-menu-item {
  color: rgba(255,255,255,0.7);
}
.admin-menu .el-menu-item.is-active {
  background: #1890ff;
  color: #fff;
}
.admin-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid #e8e8e8;
  background: #fff;
}
.page-title { font-size: 18px; font-weight: 600; }
.admin-user {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  color: #606266;
}
.admin-main { background: #f0f2f5; }
</style>