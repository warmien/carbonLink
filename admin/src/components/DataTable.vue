<template>
  <el-table :data="data" stripe border style="width: 100%" v-loading="loading">
    <el-table-column v-for="col in columns" :key="col.prop" :prop="col.prop" :label="col.label" :width="col.width" :formatter="col.formatter" />
  </el-table>
  <el-pagination
    v-if="total > pageSize"
    layout="prev, pager, next"
    :total="total"
    :page-size="pageSize"
    :current-page="currentPage"
    @current-change="handlePageChange"
    style="margin-top: 16px; justify-content: flex-end"
  />
</template>

<script setup lang="ts">
const props = defineProps<{
  data: any[]
  columns: { prop: string; label: string; width?: number; formatter?: any }[]
  total?: number
  pageSize?: number
  currentPage?: number
  loading?: boolean
}>()

const emit = defineEmits<{
  (e: 'page-change', page: number): void
}>()

function handlePageChange(page: number): void {
  emit('page-change', page)
}
</script>