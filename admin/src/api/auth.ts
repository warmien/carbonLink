import request from './index'

export const authApi = {
  login(username: string, password: string): Promise<{ token: string; role: string }> {
    return request.post('/auth/login', { username, password })
  },

  logout(): Promise<void> {
    return request.post('/auth/logout')
  },

  getProfile(): Promise<any> {
    return request.get('/auth/profile')
  }
}