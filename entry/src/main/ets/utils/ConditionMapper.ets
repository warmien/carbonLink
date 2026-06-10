import { ProductCondition } from '../models/Product';

export class ConditionMapper {
  static mapCondition(conditionDesc: string): string | null {
    if (!conditionDesc) return null;
    const desc = conditionDesc.toLowerCase().replace(/\s/g, '');

    if (/a级|全新|未使用|未拆封|brand\s*new/.test(desc)) {
      return ProductCondition.A_GRADE;
    }
    if (/b级|99成新|9\.9成新|几乎全新|like\s*new/.test(desc)) {
      return ProductCondition.B_GRADE;
    }
    if (/c级|95成新|9\.5成新|轻微使用/.test(desc)) {
      return ProductCondition.C_GRADE;
    }
    if (/d级|9成新|正常使用/.test(desc)) {
      return ProductCondition.D_GRADE;
    }
    if (/e级|8成新|明显使用/.test(desc)) {
      return ProductCondition.E_GRADE;
    }
    if (/f级|7成新|使用痕迹严重/.test(desc)) {
      return ProductCondition.F_GRADE;
    }
    return null;
  }
}
