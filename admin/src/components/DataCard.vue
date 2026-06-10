<template>
  <el-card shadow="hover" class="data-card">
    <div class="data-card-content">
      <div class="data-card-icon" :style="{ backgroundColor: iconBg }">
        <el-icon :size="24"><component :is="icon" /></el-icon>
      </div>
      <div class="data-card-info">
        <div class="data-card-value">{{ displayValue }}</div>
        <div class="data-card-label">{{ label }}</div>
      </div>
    </div>
    <div v-if="trend !== undefined" class="data-card-trend" :class="trendClass">
      <el-icon :size="14"><component :is="trendIcon" /></el-icon>
      <span>{{ Math.abs(trend) }}%</span>
    </div>
  </el-card>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { TrendCharts, TrendChartsBottom } from '@element-plus/icons-vue'

const props = defineProps<{
  label: string
  value: number | string
  icon: any
  iconBg?: string
  trend?: number
  suffix?: string
}>()

const displayValue = computed(() => {
  if (typeof props.value === 'number') {
    return props.value.toLocaleString() + (props.suffix || '')
  }
  return props.value
})

const trendClass = computed(() => props.trend !== undefined && props.trend >= 0 ? 'trend-up' : 'trend-down')
const trendIcon = computed(() => props.trend !== undefined && props.trend >= 0 ? TrendCharts : TrendChartsBottom)
</script>

<style scoped>
.data-card-content {
  display: flex;
  align-items: center;
  gap: 12px;
}
.data-card-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
}
.data-card-value {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
}
.data-card-label {
  font-size: 13px;
  color: #909399;
  margin-top: 2px;
}
.data-card-trend {
  margin-top: 8px;
  font-size: 13px;
  display: flex;
  align-items: center;
  gap: 2px;
}
.trend-up { color: #67c23a; }
.trend-down { color: #f56c6c; }
</style>