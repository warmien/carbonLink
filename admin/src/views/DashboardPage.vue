<template>
  <div class="dashboard-page">
    <div class="overview-cards">
      <DataCard label="今日DAU" :value="overview.dau || 0" :icon="User" iconBg="#409eff" />
      <DataCard label="今日新增用户" :value="overview.todayNewUsers || 0" :icon="UserFilled" iconBg="#67c23a" />
      <DataCard label="今日交易量" :value="overview.todayOrders || 0" :icon="Goods" iconBg="#e6a23c" />
      <DataCard label="今日碳积分发放" :value="overview.todayCreditEarned || 0" :icon="Sunny" iconBg="#f56c6c" suffix="分" />
    </div>
    <div class="trend-section">
      <ChartCard title="近7天用户增长趋势" :option="trendOption" :height="350" />
    </div>
    <div class="quick-links">
      <el-row :gutter="16">
        <el-col :span="8">
          <el-card shadow="hover" class="quick-card" @click="$router.push('/user')">
            <el-icon :size="32" color="#409eff"><User /></el-icon>
            <div>用户分析</div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover" class="quick-card" @click="$router.push('/product')">
            <el-icon :size="32" color="#67c23a"><Goods /></el-icon>
            <div>商品分析</div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card shadow="hover" class="quick-card" @click="$router.push('/carbon')">
            <el-icon :size="32" color="#e6a23c"><Sunny /></el-icon>
            <div>碳减排分析</div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { User, UserFilled, Goods, Sunny } from '@element-plus/icons-vue'
import { analyticsApi } from '../api/analytics'
import DataCard from '../components/DataCard.vue'
import ChartCard from '../components/ChartCard.vue'

const overview = ref<Record<string, any>>({})
const trendData = ref<any[]>([])

const trendOption = computed(() => ({
  tooltip: { trigger: 'axis' },
  xAxis: { type: 'category', data: trendData.value.map((d: any) => d.date?.slice(5) || '') },
  yAxis: { type: 'value' },
  series: [{
    name: '新增用户',
    type: 'line',
    smooth: true,
    data: trendData.value.map((d: any) => d.count || 0),
    areaStyle: { opacity: 0.3 },
    itemStyle: { color: '#409eff' }
  }]
}))

onMounted(async () => {
  try {
    const [ov, tr] = await Promise.all([
      analyticsApi.getDashboardOverview(),
      analyticsApi.getDashboardTrend(7)
    ])
    overview.value = ov
    trendData.value = Array.isArray(tr) ? tr : []
  } catch (e) {}
})
</script>

<style scoped>
.dashboard-page { padding: 0; }
.overview-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}
.trend-section { margin-bottom: 24px; }
.quick-card {
  text-align: center;
  cursor: pointer;
  padding: 20px 0;
}
.quick-card div { margin-top: 8px; color: #606266; }
</style>