<template>
  <el-button :icon="Download" size="small" @click="handleExport" :loading="exporting">
    导出{{ format.toUpperCase() }}
  </el-button>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Download } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const props = defineProps<{
  reportType: string
  format?: 'csv' | 'xlsx'
  startDate?: string
  endDate?: string
}>()

const exporting = ref(false)

async function handleExport(): void {
  exporting.value = true
  try {
    const params = new URLSearchParams()
    params.set('format', props.format || 'xlsx')
    if (props.startDate) params.set('startDate', props.startDate)
    if (props.endDate) params.set('endDate', props.endDate)

    const token = localStorage.getItem('admin_token')
    const resp = await fetch(`/api/export/${props.reportType}?${params.toString()}`, {
      headers: { Authorization: `Bearer ${token}` }
    })

    if (!resp.ok) throw new Error('导出失败')

    const blob = await resp.blob()
    const contentDisposition = resp.headers.get('Content-Disposition')
    let filename = `carbonlink_${props.reportType}.${props.format || 'xlsx'}`
    if (contentDisposition) {
      const match = contentDisposition.match(/filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/)
      if (match) filename = decodeURIComponent(match[1].replace(/['"]/g, ''))
    }

    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = filename
    a.click()
    URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } catch (e) {
    ElMessage.error('导出失败')
  } finally {
    exporting.value = false
  }
}
</script>