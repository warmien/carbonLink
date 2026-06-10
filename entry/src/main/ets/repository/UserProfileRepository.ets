import { UserProfile, CategoryWeight } from '../models/UserProfile';

export class UserProfileRepository {
  private profiles: Map<string, UserProfile> = new Map();

  getProfile(userId: string): UserProfile {
    let profile = this.profiles.get(userId);
    if (!profile) {
      profile = new UserProfile();
      profile.userId = userId;
    }
    return profile;
  }

  saveProfile(profile: UserProfile): void {
    profile.lastUpdated = Date.now();
    this.profiles.set(profile.userId, profile);
  }

  hasProfile(userId: string): boolean {
    const profile = this.profiles.get(userId);
    if (!profile) return false;
    return profile.preferredCategories.length > 0;
  }
}

export const userProfileRepository = new UserProfileRepository();