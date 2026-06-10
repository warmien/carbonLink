import { Recommendation, RecStrategy } from '../models/Recommendation';
import { UserProfile } from '../models/UserProfile';
import { userProfileRepository } from '../repository/UserProfileRepository';
import { behaviorRepository } from '../repository/BehaviorRepository';
import { productRepository } from '../repository/ProductRepository';
import { RecommendationConfig } from '../config/RecommendationConfig';
import { Product } from '../models/Product';

export class RecommendationEngine {
  static getHomeRecommendations(userId: string, limit: number): Recommendation[] {
    try {
      const hasProfile = userProfileRepository.hasProfile(userId);
      if (!hasProfile) {
        return RecommendationEngine.coldStartRecommend(limit);
      }

      const profile = userProfileRepository.getProfile(userId);
      const allProducts = productRepository.getProducts();
      const disliked = behaviorRepository.getDislikedProductIds(userId);
      const candidates = allProducts.filter((p: Product): boolean =>
        p.status === 'selling' && p.sellerId !== userId && disliked.indexOf(p.id) === -1
      );

      const scored: Recommendation[] = [];
      for (let i = 0; i < candidates.length; i++) {
        const p = candidates[i];
        let score = 0;
        let reason = '';
        let strategy = RecStrategy.POPULARITY;

        const contentScore = RecommendationEngine.contentScore(p, profile);
        const popScore = RecommendationEngine.popularityScore(p);

        score = contentScore * RecommendationConfig.WEIGHT_CONTENT +
          popScore * RecommendationConfig.WEIGHT_POPULARITY;

        if (contentScore > 0.3) {
          reason = '因为你浏览过' + p.category + '类商品';
          strategy = RecStrategy.CONTENT_BASED;
        } else {
          reason = '热门好物';
          strategy = RecStrategy.POPULARITY;
        }

        const rec = new Recommendation();
        rec.productId = p.id;
        rec.score = score;
        rec.reason = reason;
        rec.strategy = strategy;
        scored.push(rec);
      }

      scored.sort((a: Recommendation, b: Recommendation): number => b.score - a.score);

      const diverse = RecommendationEngine.ensureDiversity(scored, candidates);
      return diverse.slice(0, limit);
    } catch (e) {
      return RecommendationEngine.coldStartRecommend(limit);
    }
  }

  static getSimilarRecommendations(productId: string, userId: string, limit: number): Recommendation[] {
    const current = productRepository.getProductById(productId);
    if (!current) return [];

    const allProducts = productRepository.getProducts();
    const disliked = behaviorRepository.getDislikedProductIds(userId);
    const similar = allProducts.filter((p: Product): boolean =>
      p.id !== productId && p.sellerId !== userId && p.status === 'selling' &&
      p.category === current.category && disliked.indexOf(p.id) === -1
    );

    const results: Recommendation[] = [];
    for (let i = 0; i < similar.length && i < limit; i++) {
      const rec = new Recommendation();
      rec.productId = similar[i].id;
      rec.score = 1.0 - Math.abs(similar[i].price - current.price) / (current.price + 1);
      rec.reason = '与你浏览的商品相似';
      rec.strategy = RecStrategy.CONTENT_BASED;
      results.push(rec);
    }
    results.sort((a: Recommendation, b: Recommendation): number => b.score - a.score);
    return results;
  }

  private static coldStartRecommend(limit: number): Recommendation[] {
    const allProducts = productRepository.getProducts();
    const popular = allProducts.filter((p: Product): boolean => p.status === 'selling');
    popular.sort((a: Product, b: Product): number => b.viewCount - a.viewCount);

    const results: Recommendation[] = [];
    for (let i = 0; i < popular.length && i < limit; i++) {
      const rec = new Recommendation();
      rec.productId = popular[i].id;
      rec.score = 1.0 - i * 0.05;
      rec.reason = '为你精选';
      rec.strategy = RecStrategy.COLD_START;
      results.push(rec);
    }
    return results;
  }

  private static contentScore(product: Product, profile: UserProfile): number {
    for (let i = 0; i < profile.preferredCategories.length; i++) {
      if (profile.preferredCategories[i].category === product.category) {
        return profile.preferredCategories[i].weight;
      }
    }
    return 0;
  }

  private static popularityScore(product: Product): number {
    const maxViews = 1000;
    return Math.min(product.viewCount / maxViews, 1.0);
  }

  private static ensureDiversity(scored: Recommendation[], candidates: Product[]): Recommendation[] {
    const productMap = new Map<string, Product>();
    for (let i = 0; i < candidates.length; i++) {
      productMap.set(candidates[i].id, candidates[i]);
    }

    const categoryGroups = new Map<string, Recommendation[]>();
    for (let i = 0; i < scored.length; i++) {
      const p = productMap.get(scored[i].productId);
      if (!p) continue;
      const list = categoryGroups.get(p.category);
      if (list) {
        list.push(scored[i]);
      } else {
        categoryGroups.set(p.category, [scored[i]]);
      }
    }

    const categories: string[] = [];
    categoryGroups.forEach((value: Recommendation[], key: string) => {
      categories.push(key);
    });

    const result: Recommendation[] = [];
    const usedIds: string[] = [];
    let catIndex = 0;
    let round = 0;
    const maxRounds = scored.length;

    while (result.length < scored.length && round < maxRounds) {
      if (categories.length === 0) break;
      const cat = categories[catIndex % categories.length];
      const group = categoryGroups.get(cat);
      if (group) {
        for (let j = 0; j < group.length; j++) {
          if (usedIds.indexOf(group[j].productId) === -1) {
            result.push(group[j]);
            usedIds.push(group[j].productId);
            break;
          }
        }
      }
      catIndex++;
      round++;
    }
    return result;
  }
}