// 碳积分计算条目：每个子类别对应一个碳减排量和碳积分范围
// 核心公式：碳减排量 = (minReduction + maxReduction) / 2 × conditionFactor
export class CarbonCreditEntry {
  name: string = '';
  minReduction: number = 0;
  maxReduction: number = 0;
  minCredits: number = 0;
  maxCredits: number = 0;

  constructor(name: string, minReduction: number, maxReduction: number, minCredits: number, maxCredits: number) {
    this.name = name;
    this.minReduction = minReduction;
    this.maxReduction = maxReduction;
    this.minCredits = minCredits;
    this.maxCredits = maxCredits;
  }
}

// 成色系数：成色越好，碳减排价值越高（延长产品完整使用寿命，避免新品制造碳排放）
export class ConditionFactor {
  static readonly FACTORS: Record<string, number> = {
    'A级-全新未用': 1.0,
    'B级-99成新': 0.85,
    'C级-95成新': 0.7,
    'D级-9成新': 0.55,
    'E级-8成新': 0.4,
    'F级-7成新': 0.25
  };

  static getFactor(condition: string): number {
    const factor = ConditionFactor.FACTORS[condition];
    return factor !== undefined ? factor : 0.5;
  }
}

export class CarbonCreditTable {
  static readonly TABLE: Record<string, CarbonCreditEntry[]> = {
    '电子数码': [
      new CarbonCreditEntry('旧手机', 25, 30.41, 25, 30.41),
      new CarbonCreditEntry('平板电脑', 130, 280, 130, 280),
      new CarbonCreditEntry('蓝牙耳机', 6.92, 10.36, 6.92, 10.36),
      new CarbonCreditEntry('有线耳机', 1.27, 9.07, 1.27, 9.07),
      new CarbonCreditEntry('充电宝', 15, 25, 15, 25),
      new CarbonCreditEntry('智能手表', 1.1, 6.1, 1.1, 6.1),
      new CarbonCreditEntry('鼠标', 9.96, 32, 9.96, 32),
      new CarbonCreditEntry('键盘', 1.82, 10.17, 1.82, 10.17),
      new CarbonCreditEntry('显示器', 25, 100, 25, 100),
      new CarbonCreditEntry('吹风机', 8.3, 42.6, 8.3, 42.6),
      new CarbonCreditEntry('46级耳机', 1.5, 3.0, 1.5, 3.0),
      new CarbonCreditEntry('46级收音机', 2.0, 4.5, 2.0, 4.5),
      new CarbonCreditEntry('插座', 1.62, 2.35, 1.62, 2.35)
    ],
    '图书教材': [
      new CarbonCreditEntry('书籍', 4, 6, 4, 6),
      new CarbonCreditEntry('笔记本', 0.3, 0.3, 0.3, 0.3),
      new CarbonCreditEntry('考研网课账号', 0.2, 0.2, 0.2, 0.2)
    ],
    '服装鞋帽': [
      new CarbonCreditEntry('外套', 4.2, 33.39, 4.2, 33.39),
      new CarbonCreditEntry('包', 12, 45, 12, 45),
      new CarbonCreditEntry('帽子', 0.2, 5.5, 0.2, 5.5),
      new CarbonCreditEntry('袜子类', 0.2, 0.4, 0.2, 0.4),
      new CarbonCreditEntry('丝巾类', 0.4, 0.6, 0.4, 0.6)
    ],
    '家居生活': [
      new CarbonCreditEntry('小电煮锅', 3, 10, 3, 10),
      new CarbonCreditEntry('台灯', 8.2, 18.7, 8.2, 18.7),
      new CarbonCreditEntry('散热架', 2, 8, 2, 8),
      new CarbonCreditEntry('收纳用品', 0.5, 5, 0.5, 5),
      new CarbonCreditEntry('开水瓶', 2.29, 48, 2.29, 48),
      new CarbonCreditEntry('鞋架', 1, 5, 1, 5),
      new CarbonCreditEntry('小风扇', 1.8, 2.5, 1.8, 2.5),
      new CarbonCreditEntry('挂钩', 0.05, 0.2, 0.05, 0.2),
      new CarbonCreditEntry('衣架', 0.11, 1.82, 0.11, 1.82),
      new CarbonCreditEntry('体重秤', 1, 5, 1, 5),
      new CarbonCreditEntry('小桌板', 2.5, 2.5, 2.5, 2.5),
      new CarbonCreditEntry('手机支架', 1.62, 2.35, 1.62, 2.35),
      new CarbonCreditEntry('小刀', 0.5, 2, 0.5, 2),
      new CarbonCreditEntry('剪刀', 0.5, 2.3, 0.5, 2.3),
      new CarbonCreditEntry('鞋子除臭喷雾', 0.1, 0.5, 0.1, 0.5)
    ],
    '美妆护肤': [
      new CarbonCreditEntry('面部护肤类', 1.0, 1.2, 1.0, 1.2),
      new CarbonCreditEntry('面膜类', 0.4, 0.5, 0.4, 0.5),
      new CarbonCreditEntry('防晒类', 0.6, 0.7, 0.6, 0.7),
      new CarbonCreditEntry('卸妆清洁类', 0.5, 0.8, 0.5, 0.8),
      new CarbonCreditEntry('底妆类', 0.8, 1.0, 0.8, 1.0),
      new CarbonCreditEntry('眼妆类', 0.5, 0.6, 0.5, 0.6),
      new CarbonCreditEntry('唇妆类', 0.3, 0.4, 0.3, 0.4),
      new CarbonCreditEntry('面部彩妆类', 0.5, 0.7, 0.5, 0.7),
      new CarbonCreditEntry('美甲类', 0.4, 0.6, 0.4, 0.6),
      new CarbonCreditEntry('身体洗护类', 1.0, 1.5, 1.0, 1.5),
      new CarbonCreditEntry('身体护理类', 0.7, 1.0, 0.7, 1.0),
      new CarbonCreditEntry('手部护理类', 0.3, 0.5, 0.3, 0.5),
      new CarbonCreditEntry('头发洗护类', 1.2, 1.8, 1.2, 1.8),
      new CarbonCreditEntry('美发造型类', 3.0, 3.5, 3.0, 3.5),
      new CarbonCreditEntry('美发饰品类', 0.2, 0.3, 0.2, 0.3),
      new CarbonCreditEntry('美妆工具类', 0.5, 0.8, 0.5, 0.8),
      new CarbonCreditEntry('香水香氛类', 1.2, 1.5, 1.2, 1.5),
      new CarbonCreditEntry('美妆收纳盒类', 1.5, 2.0, 1.5, 2.0),
      new CarbonCreditEntry('化妆包类', 0.8, 1.2, 0.8, 1.2),
      new CarbonCreditEntry('美妆家居类', 4.0, 6.0, 4.0, 6.0),
      new CarbonCreditEntry('颈部配饰类', 0.8, 1.0, 0.8, 1.0),
      new CarbonCreditEntry('耳部配饰类', 0.4, 0.5, 0.4, 0.5),
      new CarbonCreditEntry('手部配饰类', 0.6, 0.8, 0.6, 0.8),
      new CarbonCreditEntry('服饰配饰类', 0.5, 0.7, 0.5, 0.7),
      new CarbonCreditEntry('美妆小家电类', 6.5, 8.0, 6.5, 8.0),
      new CarbonCreditEntry('女士护理类', 0.6, 1.0, 0.6, 1.0)
    ],
    '运动户外': [
      new CarbonCreditEntry('羽毛球', 0.1, 0.1, 0.1, 0.1),
      new CarbonCreditEntry('羽毛球拍', 2.0, 2.0, 2.0, 2.0),
      new CarbonCreditEntry('乒乓球', 0.1, 0.1, 0.1, 0.1),
      new CarbonCreditEntry('乒乓球拍', 2.0, 2.0, 2.0, 2.0),
      new CarbonCreditEntry('篮球', 0.5, 0.5, 0.5, 0.5),
      new CarbonCreditEntry('跳绳', 0.1, 0.1, 0.1, 0.1),
      new CarbonCreditEntry('自行车', 15.0, 15.0, 15.0, 15.0),
      new CarbonCreditEntry('电动车', 50.0, 50.0, 50.0, 50.0),
      new CarbonCreditEntry('健身卡', 0.5, 0.5, 0.5, 0.5),
      new CarbonCreditEntry('水卡', 0.85, 0.85, 0.85, 0.85)
    ],
    '文具办公': [
      new CarbonCreditEntry('文具', 0.4, 0.8, 0.4, 0.8),
      new CarbonCreditEntry('计算器', 1, 1, 1, 1),
      new CarbonCreditEntry('背书椅', 4, 9, 4, 9)
    ],
    '乐器文创': [
      new CarbonCreditEntry('二手乐器', 8.0, 8.0, 8.0, 8.0),
      new CarbonCreditEntry('文创产品', 3.0, 3.0, 3.0, 3.0),
      new CarbonCreditEntry('绿植', 0.5, 0.5, 0.5, 0.5)
    ],
    '虚拟服务': [
      new CarbonCreditEntry('考研网课账号', 0.2, 0.2, 0.2, 0.2),
      new CarbonCreditEntry('健身卡', 0.5, 0.5, 0.5, 0.5),
      new CarbonCreditEntry('水卡', 0.85, 0.85, 0.85, 0.85)
    ],
    '其他闲置': []
  };

  // 子类别查找算法：1.精确匹配 → 2.模糊匹配(去"类"字双向包含) → 3.兜底取类别首项 → 4.返回null
  static getEntry(category: string, subCategory: string): CarbonCreditEntry | null {
    const entries = CarbonCreditTable.TABLE[category];
    if (!entries) {
      return null;
    }
    for (let i = 0; i < entries.length; i++) {
      if (entries[i].name === subCategory) {
        return entries[i];
      }
    }
    for (let i = 0; i < entries.length; i++) {
      const entryName = entries[i].name.replace('类', '');
      const subName = subCategory.replace('类', '');
      if (entryName.indexOf(subName) >= 0 || subName.indexOf(entryName) >= 0) {
        return entries[i];
      }
    }
    if (entries.length > 0) {
      return entries[0];
    }
    return null;
  }

  // 核心计算：碳减排量/碳积分 = 区间均值 × 成色系数，保留2位小数
  static calculate(category: string, subCategory: string, condition: string): CarbonCreditResult {
    const entry = CarbonCreditTable.getEntry(category, subCategory);
    if (!entry) {
      return new CarbonCreditResult(0, 0);
    }
    const factor = ConditionFactor.getFactor(condition);
    const avgReduction = (entry.minReduction + entry.maxReduction) / 2;
    const avgCredits = (entry.minCredits + entry.maxCredits) / 2;
    const reduction = Math.round(avgReduction * factor * 100) / 100;
    const credits = Math.round(avgCredits * factor * 100) / 100;
    return new CarbonCreditResult(reduction, credits);
  }
}

export class CarbonCreditResult {
  carbonReduction: number = 0;
  carbonCredits: number = 0;

  constructor(carbonReduction: number, carbonCredits: number) {
    this.carbonReduction = carbonReduction;
    this.carbonCredits = carbonCredits;
  }
}