export class SKU {
  id: string = ''
  spuId: string = ''
  price: number = 0
  originalPrice: number = 0
  condition: string = ''
  carbonReduction: number = 0
  carbonCredits: number = 0
  status: string = 'on_sale'
  skuCode: string = ''
  availableStock: number = 1
  specValues: SpecValueItem[] = []
  createdAt: number = Date.now()
  updatedAt: number = Date.now()
}

export enum SKUStatus {
  ON_SALE = 'on_sale',
  OFF_SALE = 'off_sale',
  SOLD_OUT = 'sold_out'
}

export class SpecValueItem {
  specNameId: number = 0
  specName: string = ''
  specValueId: number = 0
  specValue: string = ''
}