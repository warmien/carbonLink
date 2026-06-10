<template>
  <div class="analytics-page">
    <div class="page-toolbar">
      <TimeRangeSelector @change="handleTimeChange" />
      <ExportButton report-type="product_trend" :start-date="startDate" :end-date="endDate" style="margin-left: 12px" />
    </div>

    <div class="stats-cards">
      <DataCard label="总订单数" :value="transaction.totalOrders || 0" :icon="Goods" iconBg="#409eff" />
      <DataCard label="已完成订单" :value="transaction.completedOrders || 0" :icon="CircleCheck" iconBg="#67c23a" />
      <DataCard label="成交金额" :value="transaction.completedAmount || 0" :icon="Money" iconBg="#e6a23c" suffix="元" />
      <DataCard label="成交率" :value="((transaction.completionRate || 0) * 100).toFixed(1)" :icon="TrendCharts" iconBg="#f56c6c" suffix="%" />
    </div>

    <el-row :gutter="16">
      <el-col :span="12">
        <ChartCard title="商品发布趋势" :option="trendOption" :height="300" />
      </el-col>
      <el-col :span="12">
        <ChartCard title="分类分布" :option="categoryOption" :height="300" />
      </el-col>
    </el-row>

    <el-row :gutter="16" style="margin-top: 16px">
      <el-col :span="12">
        <ChartCard title="价格区间分布" :option="priceOption" :height="300" />
      </el-col>
      <el-col :span="12">
        <ChartCard title="成色分布" :option="conditionOption" :height="300" />
      </el-col>
    </el-row>

    <el-card shadow="hover" style="margin-top: 16px">
      <template #header>
        <div style="display:flex;justify-content:space-between;align-items:center">
          <span style="font-weight:600">热门商品排行</span>
          <el-radio-group v-model="rankingMetric" size="small" @change="loadRanking">
            <el-radio-button label="viewCount">浏览量</el-radio-button>
            <el-radio-button label="favoriteCount">收藏量</el-radio-button>
          </el-radio-group>
        </div>
      </template>
      <el-table :data="ranking" stripe>
        <el-table-column prop="rank" label="排名" width="70" />
        <el-table-column prop="title" label="商品名称" />
        <el-table-column prop="value" label="数值" width="100" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { Goods, CircleCheck, Money, TrendCharts } from '@element-plus/icons-vue'
import { analyticsApi } from '../api/analytics'
import DataCard from '../components/DataCard.vue'
import ChartCard from '../components/ChartCard.vue'
import TimeRangeSelector from '../components/TimeRangeSelector.vue'
import ExportButton from '../components/ExportButton.vue'

const startDate = ref<string>()
const endDate = ref<string>()
const trend = ref<any>({})
const transaction = ref<any>({})
const categoryDist = ref<any>({})
const priceDist = ref<any>({})
const conditionDist = ref<any>({})
const ranking = ref<any[]>([])
const rankingMetric = ref('viewCount')

const trendOption = computed(() => {
  const data = trend.value.trend || []
  return {
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: data.map((d: any) => d.date?.slice(5) || '') },
    yAxis: { type: 'value' },
    series: [{ name: '发布量', type: 'line', smooth: true, data: data.map((d: any) => d.count), areaStyle: { opacity: 0.3 }, itemStyle: { color: '#67c23a' } }]
  }
})

const categoryOption = computed(() => {
  const dist = categoryDist.value.distribution || {}
  return {
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: Object.keys(dist) },
    yAxis: { type: 'value' },
    series: [{ type: 'bar', data: Object.values(dist), itemStyle: { color: '#409eff' } }]
  }
})

const priceOption = computed(() => {
  const dist = priceDist.value.distribution || {}
  return {
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: Object.keys(dist) },
    yAxis: { type: 'value' },
    series: [{ type: 'bar', data: Object.values(dist), itemStyle: { color: '#e6a23c' } }]
  }
})

const conditionOption = computed(() => {
  const dist = conditionDist.value.distribution || {}
  return {
    tooltip: { trigger: 'item' },
    series: [{ type: 'pie', radius: ['40%', '70%'], data: Object.entries(dist).map(([name, value]) => ({ name, value })), emphasis: { itemStyle: { shadowBlur: 10 } } }]
  }
})

function handleTimeChange(start?: string, end?: string): void {
  startDate.value = start
  endDate.value = end
  loadData()
}

async function loadData(): Promise<void> {
  try {
    const [t, tx, c, p, cd] = await Promise.all([
      analyticsApi.getProductTrend(startDate.value, endDate.value),
      analyticsApi.getProductTransaction(),
      analyticsApi.getProductCategoryDistribution(),
      analyticsApi.getProductPriceDistribution(),
      analyticsApi.getProductConditionDistribution()
    ])
    trend.value = t
    transaction.value = tx
    categoryDist.value = c
    priceDist.value = p
    conditionDist.value = cd
  } catch (e) {}
}

async function loadRanking(): Promise<void> {
  try {
    const res = await analyticsApi.getProductHotRanking(rankingMetric.value, 10)
    ranking.value = res.ranking || []
  } catch (e) {}
}

onMounted(() => {
  loadData()
  loadRanking()
})
</script>

<style scoped>
.analytics-page { padding: 0; }
.page-toolbar { display: flex; align-items: center; margin-bottom: 16px; }
.stats-cards { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 16px; }
</style>