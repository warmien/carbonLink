import { ProductCondition } from '../models/Product';

export class ConditionMapper {
  static mapCondition(conditionDesc: string): string | null {
    if (!conditionDesc) return null;
    const desc = conditionDesc.toLowerCase().replace(/\s/g, '');

    if (/全新|未使用|未拆封|brand\s*new/.test(desc)) {
      return ProductCondition.BRAND_NEW;
    }
    if (/几乎全新|9成新|95新|9\.5成新|like\s*new/.test(desc)) {
      return ProductCondition.LIKE_NEW;
    }
    if (/轻微使用|8成新|85新|8\.5成新|lightly\s*used/.test(desc)) {
      return ProductCondition.LIGHTLY_USED;
    }
    if (/正常使用|7成新|明显使用|7\.5成新|normal\s*used/.test(desc)) {
      return ProductCondition.NORMAL_USED;
    }
    return null;
  }
}