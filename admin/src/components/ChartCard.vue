<template>
  <el-card :shadow="shadow" class="chart-card">
    <template #header>
      <div class="chart-card-header">
        <span class="chart-card-title">{{ title }}</span>
        <slot name="header-extra" />
      </div>
    </template>
    <div ref="chartRef" :style="{ height: height + 'px' }" />
  </el-card>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'
import * as echarts from 'echarts'

const props = defineProps<{
  title: string
  option: Record<string, any>
  height?: number
  shadow?: string
}>()

const chartRef = ref<HTMLElement>()
let chartInstance: echarts.ECharts | null = null

onMounted(() => {
  if (chartRef.value) {
    chartInstance = echarts.init(chartRef.value)
    chartInstance.setOption(props.option)
  }
})

watch(() => props.option, (newOption) => {
  if (chartInstance) {
    chartInstance.setOption(newOption, true)
  }
}, { deep: true })

onUnmounted(() => {
  chartInstance?.dispose()
})
</script>

<style scoped>
.chart-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.chart-card-title {
  font-weight: 600;
  font-size: 15px;
}
</style>