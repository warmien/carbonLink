import { Recommendation, RecStrategy } from '../models/Recommendation';
import { SPU } from '../models/SPU';
import { productRepository, SPUListResult } from '../repository/ProductRepository';
import { RecommendationConfig } from '../config/RecommendationConfig';

export class RecommendationEngine {
  static async getHomeRecommendations(userId: string, limit: number): Promise<Recommendation[]> {
    try {
      const result: SPUListResult = await productRepository.fetchProducts();
      const candidates: SPU[] = result.list.filter((spu: SPU): boolean =>
        spu.status === 'on_sale' && spu.sellerId !== userId
      );

      const scored: Recommendation[] = [];
      for (let i = 0; i < candidates.length; i++) {
        const p = candidates[i];
        let score = 0;
        let reason = '';
        let strategy = RecStrategy.POPULARITY;

        const popScore = RecommendationEngine.popularityScore(p);
        score = popScore * RecommendationConfig.WEIGHT_POPULARITY;

        if (popScore > 0.3) {
          reason = '热门好物';
          strategy = RecStrategy.POPULARITY;
        } else {
          reason = '为你精选';
          strategy = RecStrategy.COLD_START;
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

  static async getSimilarRecommendations(productId: string, userId: string, limit: number): Promise<Recommendation[]> {
    try {
      const detailResult = await productRepository.getProductDetail(productId);
      if (!detailResult) return [];

      const currentSpu = detailResult.spu;
      const result: SPUListResult = await productRepository.fetchProducts('categoryId=' + currentSpu.categoryId.toString());
      const similar = result.list.filter((spu: SPU): boolean =>
        spu.id !== productId && spu.sellerId !== userId && spu.status === 'on_sale'
      );

      const results: Recommendation[] = [];
      for (let i = 0; i < similar.length && i < limit; i++) {
        const rec = new Recommendation();
        rec.productId = similar[i].id;
        rec.score = 1.0 - Math.abs(similar[i].minPrice - currentSpu.minPrice) / (currentSpu.minPrice + 1);
        rec.reason = '与你浏览的商品相似';
        rec.strategy = RecStrategy.CONTENT_BASED;
        results.push(rec);
      }
      results.sort((a: Recommendation, b: Recommendation): number => b.score - a.score);
      return results;
    } catch (e) {
      return [];
    }
  }

  private static async coldStartRecommend(limit: number): Promise<Recommendation[]> {
    try {
      const result: SPUListResult = await productRepository.fetchProducts();
      const popular = result.list.filter((spu: SPU): boolean => spu.status === 'on_sale');
      popular.sort((a: SPU, b: SPU): number => b.viewCount - a.viewCount);

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
    } catch (e) {
      return [];
    }
  }

  private static popularityScore(spu: SPU): number {
    const maxViews = 1000;
    return Math.min(spu.viewCount / maxViews, 1.0);
  }

  private static ensureDiversity(scored: Recommendation[], candidates: SPU[]): Recommendation[] {
    const productMap = new Map<string, SPU>();
    for (let i = 0; i < candidates.length; i++) {
      productMap.set(candidates[i].id, candidates[i]);
    }

    const categoryGroups = new Map<string, Recommendation[]>();
    for (let i = 0; i < scored.length; i++) {
      const p = productMap.get(scored[i].productId);
      if (!p) continue;
      const catName = p.categoryName;
      const list = categoryGroups.get(catName);
      if (list) {
        list.push(scored[i]);
      } else {
        categoryGroups.set(catName, [scored[i]]);
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
