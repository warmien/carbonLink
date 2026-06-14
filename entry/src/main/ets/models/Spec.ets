export class SpecName {
  id: number = 0
  name: string = ''
  sortOrder: number = 0
}

export class SpecValue {
  id: number = 0
  specNameId: number = 0
  value: string = ''
  sortOrder: number = 0
}

export class AttributeName {
  id: number = 0
  name: string = ''
  inputType: string = 'text'
  sortOrder: number = 0
}

export class ProductAttribute {
  attributeNameId: number = 0
  attributeName: string = ''
  attributeValue: string = ''
}

export class CategorySpecTree {
  specNameId: number = 0
  specName: string = ''
  values: SpecValue[] = []
}