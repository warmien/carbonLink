import { User } from '../models/User';
import { MockUsers } from '../mock/MockUsers';

export class UserRepository {
  getCurrentUser(): User {
    return MockUsers.getCurrentUser();
  }

  updateCurrentUser(user: User): void {
    MockUsers.updateCurrentUser(user);
  }

  getFavoriteIds(): string[] {
    return MockUsers.getFavoriteIds();
  }

  toggleFavoriteId(productId: string, isFavorited: boolean): void {
    MockUsers.toggleFavoriteId(productId, isFavorited);
  }
}

export const userRepository = new UserRepository();
