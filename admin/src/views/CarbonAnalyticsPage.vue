<template>
  <div class="analytics-page">
    <div class="page-toolbar">
      <TimeRangeSelector @change="handleTimeChange" />
      <ExportButton report-type="carbon_credit" :start-date="startDate" :end-date="endDate" style="margin-left: 12px" />
    </div>

    <div class="stats-cards">
      <DataCard label="累计碳减排" :value="reduction.totalReductionKg || 0" :icon="Sunny" iconBg="#67c23a" suffix="kg" />
      <DataCard label="完成交易数" :value="reduction.totalTrades || 0" :icon="Goods" iconBg="#409eff" />
      <DataCard label="兑换次数" :value="exchange.exchangeCount || 0" :icon="Present" iconBg="#e6a23c" />
      <DataCard label="消耗积分" :value="exchange.totalSpent || 0" :icon="Coin" iconBg="#f56c6c" suffix="分" />
    </div>

    <el-row :gutter="16">
      <el-col :span="12">
        <ChartCard title="碳积分发放趋势" :option="creditTrendOption" :height="300" />
      </el-col>
      <el-col :span="12">
        <ChartCard title="积分发放来源分布" :option="creditSourceOption" :height="300" />
      </el-col>
    </el-row>

    <el-row :gutter="16" style="margin-top: 16px">
      <el-col :span="12">
        <ChartCard title="环保成就分布" :option="achievementOption" :height="300" />
      </el-col>
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header><span style="font-weight:600">碳减排排行榜</span></template>
          <el-table :data="rankingList" stripe size="small">
            <el-table-column prop="rank" label="排名" width="60" />
            <el-table-column prop="nickname" label="用户" />
            <el-table-column prop="totalEarned" label="累计积分" width="100" />
            <el-table-column prop="level" label="等级" width="90" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="hover" style="margin-top: 16px">
      <template #header>
        <span style="font-weight:600">碳减排系数说明</span>
      </template>
      <el-descriptions :column="3" border>
        <el-descriptions-item label="每笔交易减排量">{{ reduction.coefficient || 2.5 }} kg CO₂</el-descriptions-item>
        <el-descriptions-item label="累计交易数">{{ reduction.totalTrades || 0 }} 笔</el-descriptions-item>
        <el-descriptions-item label="累计减排量">{{ reduction.totalReductionKg || 0 }} kg CO₂</el-descriptions-item>
      </el-descriptions>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { Sunny, Goods, Present, Coin } from '@element-plus/icons-vue'
import { analyticsApi } from '../api/analytics'
import DataCard from '../components/DataCard.vue'
import ChartCard from '../components/ChartCard.vue'
import TimeRangeSelector from '../components/TimeRangeSelector.vue'
import ExportButton from '../components/ExportButton.vue'

const startDate = ref<string>()
const endDate = ref<string>()
const creditTrend = ref<any>({})
const reduction = ref<any>({})
const creditSource = ref<any>({})
const exchange = ref<any>({})
const achievement = ref<any>({})
const rankingList = ref<any[]>([])

const creditTrendOption = computed(() => {
  const trend = creditTrend.value.trend || []
  return {
    tooltip: { trigger: 'axis' },
    legend: { data: ['发放', '消耗'] },
    xAxis: { type: 'category', data: trend.map((d: any) => d.date?.slice(5) || '') },
    yAxis: { type: 'value' },
    series: [
      { name: '发放', type: 'line', smooth: true, data: trend.map((d: any) => d.earned), areaStyle: { opacity: 0.3 }, itemStyle: { color: '#67c23a' } },
      { name: '消耗', type: 'line', smooth: true, data: trend.map((d: any) => d.spent), areaStyle: { opacity: 0.3 }, itemStyle: { color: '#f56c6c' } }
    ]
  }
})

const creditSourceOption = computed(() => {
  const dist = creditSource.value.distribution || {}
  const nameMap: Record<string, string> = { TRADE_REWARD: '交易奖励', PUBLISH_REWARD: '发布奖励', ACHIEVEMENT_REWARD: '成就奖励' }
  return {
    tooltip: { trigger: 'item' },
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      data: Object.entries(dist).map(([key, value]) => ({ name: nameMap[key] || key, value })),
      emphasis: { itemStyle: { shadowBlur: 10 } }
    }]
  }
})

const achievementOption = computed(() => {
  const achievements = achievement.value.achievements || []
  return {
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: achievements.map((a: any) => a.name) },
    yAxis: { type: 'value' },
    series: [
      { name: '解锁人数', type: 'bar', data: achievements.map((a: any) => a.unlockCount), itemStyle: { color: '#67c23a' } },
      { name: '解锁率(%)', type: 'line', yAxisIndex: 0, data: achievements.map((a: any) => (a.unlockRate * 100).toFixed(1)), itemStyle: { color: '#409eff' } }
    ]
  }
})

function handleTimeChange(start?: string, end?: string): void {
  startDate.value = start
  endDate.value = end
  loadData()
}

async function loadData(): Promise<void> {
  try {
    const [ct, r, cs, ex, ac, rk] = await Promise.all([
      analyticsApi.getCarbonCreditTrend(startDate.value, endDate.value),
      analyticsApi.getCarbonReductionEstimate(),
      analyticsApi.getCarbonCreditSource(),
      analyticsApi.getCarbonExchangeStats(),
      analyticsApi.getCarbonAchievementDistribution(),
      analyticsApi.getCarbonRanking(10)
    ])
    creditTrend.value = ct
    reduction.value = r
    creditSource.value = cs
    exchange.value = ex
    achievement.value = ac
    rankingList.value = rk.ranking || []
  } catch (e) {}
}

onMounted(() => loadData())
</script>

<style scoped>
.analytics-page { padding: 0; }
.page-toolbar { display: flex; align-items: center; margin-bottom: 16px; }
.stats-cards { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 16px; }
</style>