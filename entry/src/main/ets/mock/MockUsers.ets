import { User } from '../models/User';

export class MockUsers {
  private static currentUser: User = MockUsers.buildUser();

  private static buildUser(): User {
    const u = new User();
    u.id = 'u000';
    u.nickname = '碳易用户';
    u.avatar = '';
    u.phone = '138****8888';
    u.gender = 'male';
    u.bio = '绿色生活，循环利用';
    u.creditScore = 98;
    u.creditLevel = '良好';
    u.productCount = 3;
    u.soldCount = 5;
    u.followerCount = 128;
    u.followingCount = 56;
    u.joinDate = '2024-01-15';
    u.location = '深圳·南山区';
    return u;
  }

  static getCurrentUser(): User {
    return JSON.parse(JSON.stringify(MockUsers.currentUser)) as User;
  }

  static updateCurrentUser(user: User): void {
    MockUsers.currentUser.nickname = user.nickname;
    MockUsers.currentUser.avatar = user.avatar;
    MockUsers.currentUser.phone = user.phone;
    MockUsers.currentUser.gender = user.gender;
    MockUsers.currentUser.bio = user.bio;
    MockUsers.currentUser.creditScore = user.creditScore;
    MockUsers.currentUser.creditLevel = user.creditLevel;
    MockUsers.currentUser.productCount = user.productCount;
    MockUsers.currentUser.soldCount = user.soldCount;
    MockUsers.currentUser.followerCount = user.followerCount;
    MockUsers.currentUser.followingCount = user.followingCount;
    MockUsers.currentUser.joinDate = user.joinDate;
    MockUsers.currentUser.location = user.location;
  }

  private static favoriteIds: string[] = ['p001', 'p003', 'p006', 'p008'];

  static getFavoriteIds(): string[] {
    return [...MockUsers.favoriteIds];
  }

  static toggleFavoriteId(productId: string, isFavorited: boolean): void {
    if (isFavorited) {
      if (!MockUsers.favoriteIds.includes(productId)) {
        MockUsers.favoriteIds.push(productId);
      }
    } else {
      MockUsers.favoriteIds = MockUsers.favoriteIds.filter(id => id !== productId);
    }
  }
}
