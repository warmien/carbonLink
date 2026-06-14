export interface User {
  id: string;
  phone: string;
  password: string;
  nickname: string;
  avatar: string;
  gender: string;
  bio: string;
  credit_score: number;
  credit_level: string;
  product_count: number;
  sold_count: number;
  follower_count: number;
  following_count: number;
  join_date: string;
  location: string;
  status: string;
  lock_until: number;
  login_fail_count: number;
  created_at: number;
  updated_at: number;
}

export interface UserPublicProfile {
  id: string;
  nickname: string;
  avatar: string;
  phone: string;
  gender: string;
  bio: string;
  creditScore: number;
  creditLevel: string;
  productCount: number;
  soldCount: number;
  followerCount: number;
  followingCount: number;
  joinDate: string;
  location: string;
}

export enum UserStatus {
  ACTIVE = 'active',
  LOCKED = 'locked'
}