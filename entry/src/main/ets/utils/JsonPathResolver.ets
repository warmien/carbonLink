export class JsonPathResolver {
  static resolve(obj: Record<string, string | number | boolean | object>, path: string): string | null {
    if (!obj || !path) return null;
    const keys = path.split('.');
    let current: string | number | boolean | object = obj;
    for (const key of keys) {
      const arrayMatch = key.match(/^(\w+)\[(\d+)\]$/);
      if (arrayMatch) {
        const arrayKey = arrayMatch[1];
        const index = parseInt(arrayMatch[2], 10);
        if (current === null || current === undefined) return null;
        const record = current as Record<string, string | number | boolean | object>;
        const val = record[arrayKey];
        if (val === undefined || val === null) return null;
        const arr = val as (string | number | boolean | object)[];
        if (arr === null || arr === undefined || index >= arr.length) return null;
        current = arr[index];
      } else {
        if (current === null || current === undefined) return null;
        const record = current as Record<string, string | number | boolean | object>;
        const val = record[key];
        if (val === undefined || val === null) return null;
        current = val;
      }
    }
    if (current !== null && current !== undefined) {
      const strVal = String(current);
      if (strVal !== '[object Object]' && strVal !== '') return strVal;
    }
    return null;
  }
}
