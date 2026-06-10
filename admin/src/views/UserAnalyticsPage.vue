<template>
  <div class="analytics-page">
    <div class="page-toolbar">
      <TimeRangeSelector @change="handleTimeChange" />
      <ExportButton report-type="user_growth" :start-date="startDate" :end-date="endDate" style="margin-left: 12px" />
    </div>

    <div class="stats-cards">
      <DataCard label="DAU" :value="active.dau || 0" :icon="User" iconBg="#409eff" />
      <DataCard label="MAU" :value="active.mau || 0" :icon="UserFilled" iconBg="#67c23a" />
      <DataCard label="DAU/MAU" :value="((active.dauMauRatio || 0) * 100).toFixed(1)" :icon="TrendCharts" iconBg="#e6a23c" suffix="%" />
    </div>

    <el-row :gutter="16">
      <el-col :span="12">
        <ChartCard title="用户增长趋势" :option="growthOption" :height="300" />
      </el-col>
      <el-col :span="12">
        <ChartCard title="用户等级分布" :option="levelOption" :height="300" />
      </el-col>
    </el-row>

    <el-row :gutter="16" style="margin-top: 16px">
      <el-col :span="12">
        <ChartCard title="用户行为漏斗" :option="funnelOption" :height="300" />
      </el-col>
      <el-col :span="12">
        <el-card shadow="hover">
          <template #header><span style="font-weight:600">用户留存率</span></template>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="次日留存">{{ ((retention.nextDay || 0) * 100).toFixed(1) }}%</el-descriptions-item>
            <el-descriptions-item label="7日留存">{{ ((retention.day7 || 0) * 100).toFixed(1) }}%</el-descriptions-item>
            <el-descriptions-item label="30日留存">{{ ((retention.day30 || 0) * 100).toFixed(1) }}%</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="hover" style="margin-top: 16px">
      <template #header><span style="font-weight:600">用户列表</span></template>
      <DataTable :data="userList" :columns="userColumns" :total="userTotal" :page-size="20" :current-page="userPage" @page-change="loadUserList" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { User, UserFilled, TrendCharts } from '@element-plus/icons-vue'
import { analyticsApi } from '../api/analytics'
import DataCard from '../components/DataCard.vue'
import ChartCard from '../components/ChartCard.vue'
import TimeRangeSelector from '../components/TimeRangeSelector.vue'
import ExportButton from '../components/ExportButton.vue'
import DataTable from '../components/DataTable.vue'

const startDate = ref<string>()
const endDate = ref<string>()
const growth = ref<any>({})
const active = ref<any>({})
const retention = ref<any>({})
const levelDist = ref<any>({})
const funnel = ref<any>({})
const userList = ref<any[]>([])
const userTotal = ref(0)
const userPage = ref(1)

const userColumns = [
  { prop: 'id', label: 'ID', width: 80 },
  { prop: 'nickname', label: '昵称', width: 120 },
  { prop: 'creditLevel', label: '等级', width: 100 },
  { prop: 'creditScore', label: '信用分', width: 80 },
  { prop: 'productCount', label: '发布数', width: 80 },
  { prop: 'soldCount', label: '已售数', width: 80 },
  { prop: 'joinDate', label: '注册日期', width: 120 }
]

const growthOption = computed(() => {
  const trend = growth.value.trend || []
  return {
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: trend.map((d: any) => d.date?.slice(5) || '') },
    yAxis: { type: 'value' },
    series: [{ name: '新增用户', type: 'line', smooth: true, data: trend.map((d: any) => d.count), areaStyle: { opacity: 0.3 }, itemStyle: { color: '#409eff' } }]
  }
})

const levelOption = computed(() => {
  const dist = levelDist.value.distribution || {}
  return {
    tooltip: { trigger: 'item' },
    series: [{ type: 'pie', radius: ['40%', '70%'], data: Object.entries(dist).map(([name, value]) => ({ name, value })), emphasis: { itemStyle: { shadowBlur: 10 } } }]
  }
})

const funnelOption = computed(() => {
  const steps = funnel.value.steps || []
  return {
    tooltip: { trigger: 'item' },
    series: [{ type: 'funnel', left: '10%', width: '80%', data: steps.map((s: any) => ({ name: s.name, value: s.count })), label: { position: 'inside' } }]
  }
})

function handleTimeChange(start?: string, end?: string): void {
  startDate.value = start
  endDate.value = end
  loadData()
}

async function loadData(): Promise<void> {
  try {
    const [g, a, r, l, f] = await Promise.all([
      analyticsApi.getUserGrowth(startDate.value, endDate.value),
      analyticsApi.getUserActive(),
      analyticsApi.getUserRetention(),
      analyticsApi.getUserLevelDistribution(),
      analyticsApi.getUserFunnel()
    ])
    growth.value = g
    active.value = a
    retention.value = r
    levelDist.value = l
    funnel.value = f
  } catch (e) {}
}

async function loadUserList(page: number = 1): Promise<void> {
  userPage.value = page
  try {
    const res = await analyticsApi.getUserList(page, 20)
    userList.value = res.list || []
    userTotal.value = res.total || 0
  } catch (e) {}
}

onMounted(() => {
  loadData()
  loadUserList()
})
</script>

<style scoped>
.analytics-page { padding: 0; }
.page-toolbar { display: flex; align-items: center; margin-bottom: 16px; }
.stats-cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 16px; }
</style>