<template>
  <el-radio-group v-model="selectedRange" size="small" @change="handleChange">
    <el-radio-button label="today">今日</el-radio-button>
    <el-radio-button label="7d">近7天</el-radio-button>
    <el-radio-button label="30d">近30天</el-radio-button>
    <el-radio-button label="custom">自定义</el-radio-button>
  </el-radio-group>
  <el-date-picker
    v-if="selectedRange === 'custom'"
    v-model="customRange"
    type="daterange"
    range-separator="至"
    start-placeholder="开始日期"
    end-placeholder="结束日期"
    size="small"
    style="margin-left: 8px"
    @change="handleCustomChange"
  />
</template>

<script setup lang="ts">
import { ref } from 'vue'

const emit = defineEmits<{
  (e: 'change', startDate: string | undefined, endDate: string | undefined): void
}>()

const selectedRange = ref('30d')
const customRange = ref<[Date, Date] | null>(null)

function handleChange(): void {
  if (selectedRange.value === 'custom') return
  const now = new Date()
  let startDate: string | undefined
  let endDate: string | undefined = now.toISOString().slice(0, 10)

  if (selectedRange.value === 'today') {
    startDate = endDate
  } else if (selectedRange.value === '7d') {
    const d = new Date(now.getTime() - 7 * 86400000)
    startDate = d.toISOString().slice(0, 10)
  } else if (selectedRange.value === '30d') {
    const d = new Date(now.getTime() - 30 * 86400000)
    startDate = d.toISOString().slice(0, 10)
  }

  emit('change', startDate, endDate)
}

function handleCustomChange(): void {
  if (customRange.value) {
    const startDate = customRange.value[0].toISOString().slice(0, 10)
    const endDate = customRange.value[1].toISOString().slice(0, 10)
    emit('change', startDate, endDate)
  }
}
</script>