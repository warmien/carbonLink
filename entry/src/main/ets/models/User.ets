export class User {
  id: string = '';
  nickname: string = '';
  avatar: string = '';
  phone: string = '';
  gender: string = ''; // male / female
  bio: string = '';
  creditScore: number = 100;
  creditLevel: string = '良好';
  productCount: number = 0;
  soldCount: number = 0;
  followerCount: number = 0;
  followingCount: number = 0;
  joinDate: string = '';
  location: string = '';
}

export enum CreditLevel {
  EXCELLENT = '优秀',
  GOOD = '良好',
  NORMAL = '一般',
  POOR = '较差'
}
