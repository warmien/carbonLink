export class JsonPathResolver {
  static resolve(obj: object, path: string): string | null {
    if (!obj || !path) return null;
    const keys = path.split('.');
    let current: Object = obj;
    for (const key of keys) {
      const arrayMatch = key.match(/^(\w+)\[(\d+)\]$/);
      if (arrayMatch) {
        const arrayKey = arrayMatch[1];
        const index = parseInt(arrayMatch[2], 10);
        if (current === null || current === undefined) return null;
        const record = current as Record<string, Object>;
        const val = record[arrayKey];
        if (val === undefined || val === null) return null;
        if (!Array.isArray(val) || index >= (val as Object[]).length) return null;
        current = (val as Object[])[index];
      } else {
        if (current === null || current === undefined) return null;
        const record = current as Record<string, Object>;
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
