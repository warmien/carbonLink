import request from './index'

export const analyticsApi = {
  getDashboardOverview(): Promise<any> {
    return request.get('/dashboard/overview')
  },

  getDashboardTrend(days: number = 7): Promise<any> {
    return request.get('/dashboard/trend', { params: { days } })
  },

  getUserGrowth(startDate?: string, endDate?: string): Promise<any> {
    return request.get('/analytics/user/growth', { params: { startDate, endDate } })
  },

  getUserActive(): Promise<any> {
    return request.get('/analytics/user/active')
  },

  getUserRetention(): Promise<any> {
    return request.get('/analytics/user/retention')
  },

  getUserLevelDistribution(): Promise<any> {
    return request.get('/analytics/user/level-distribution')
  },

  getUserFunnel(): Promise<any> {
    return request.get('/analytics/user/funnel')
  },

  getUserList(page: number = 1, pageSize: number = 20): Promise<any> {
    return request.get('/analytics/user/list', { params: { page, pageSize } })
  },

  getProductTrend(startDate?: string, endDate?: string): Promise<any> {
    return request.get('/analytics/product/trend', { params: { startDate, endDate } })
  },

  getProductTransaction(): Promise<any> {
    return request.get('/analytics/product/transaction')
  },

  getProductCategoryDistribution(): Promise<any> {
    return request.get('/analytics/product/category-distribution')
  },

  getProductPriceDistribution(): Promise<any> {
    return request.get('/analytics/product/price-distribution')
  },

  getProductConditionDistribution(): Promise<any> {
    return request.get('/analytics/product/condition-distribution')
  },

  getProductHotRanking(metric: string = 'viewCount', limit: number = 10): Promise<any> {
    return request.get('/analytics/product/hot-ranking', { params: { metric, limit } })
  },

  getProductList(page: number = 1, pageSize: number = 20): Promise<any> {
    return request.get('/analytics/product/list', { params: { page, pageSize } })
  },

  getCarbonCreditTrend(startDate?: string, endDate?: string): Promise<any> {
    return request.get('/analytics/carbon/credit-trend', { params: { startDate, endDate } })
  },

  getCarbonReductionEstimate(): Promise<any> {
    return request.get('/analytics/carbon/reduction-estimate')
  },

  getCarbonCreditSource(): Promise<any> {
    return request.get('/analytics/carbon/credit-source')
  },

  getCarbonExchangeStats(): Promise<any> {
    return request.get('/analytics/carbon/exchange-stats')
  },

  getCarbonAchievementDistribution(): Promise<any> {
    return request.get('/analytics/carbon/achievement-distribution')
  },

  getCarbonRanking(limit: number = 10): Promise<any> {
    return request.get('/analytics/carbon/ranking', { params: { limit } })
  }
}