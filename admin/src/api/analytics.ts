import request from './index'

export const analyticsApi = {
  getDashboardOverview(): Promise<any> {
    return request.get('/api/admin/dashboard/overview')
  },

  getDashboardTrend(days: number = 7): Promise<any> {
    return request.get('/api/admin/dashboard/trend', { params: { days } })
  },

  getUserGrowth(startDate?: string, endDate?: string): Promise<any> {
    return request.get('/api/admin/user/growth', { params: { startDate, endDate } })
  },

  getUserActive(): Promise<any> {
    return request.get('/api/admin/user/active')
  },

  getUserRetention(): Promise<any> {
    return request.get('/api/admin/user/retention')
  },

  getUserLevelDistribution(): Promise<any> {
    return request.get('/api/admin/user/level-distribution')
  },

  getUserFunnel(): Promise<any> {
    return request.get('/api/admin/user/funnel')
  },

  getUserList(page: number = 1, pageSize: number = 20): Promise<any> {
    return request.get('/api/admin/user/list', { params: { page, pageSize } })
  },

  getProductTrend(startDate?: string, endDate?: string): Promise<any> {
    return request.get('/api/admin/product/trend', { params: { startDate, endDate } })
  },

  getProductTransaction(): Promise<any> {
    return request.get('/api/admin/product/transaction')
  },

  getProductCategoryDistribution(): Promise<any> {
    return request.get('/api/admin/product/category-distribution')
  },

  getProductPriceDistribution(): Promise<any> {
    return request.get('/api/admin/product/price-distribution')
  },

  getProductConditionDistribution(): Promise<any> {
    return request.get('/api/admin/product/condition-distribution')
  },

  getProductHotRanking(metric: string = 'viewCount', limit: number = 10): Promise<any> {
    return request.get('/api/admin/product/hot-ranking', { params: { metric, limit } })
  },

  getProductList(page: number = 1, pageSize: number = 20): Promise<any> {
    return request.get('/api/admin/product/list', { params: { page, pageSize } })
  },

  getCarbonCreditTrend(startDate?: string, endDate?: string): Promise<any> {
    return request.get('/api/admin/carbon/credit-trend', { params: { startDate, endDate } })
  },

  getCarbonReductionEstimate(): Promise<any> {
    return request.get('/api/admin/carbon/reduction-estimate')
  },

  getCarbonCreditSource(): Promise<any> {
    return request.get('/api/admin/carbon/credit-source')
  },

  getCarbonExchangeStats(): Promise<any> {
    return request.get('/api/admin/carbon/exchange-stats')
  },

  getCarbonAchievementDistribution(): Promise<any> {
    return request.get('/api/admin/carbon/achievement-distribution')
  },

  getCarbonRanking(limit: number = 10): Promise<any> {
    return request.get('/api/admin/carbon/ranking', { params: { limit } })
  }
}