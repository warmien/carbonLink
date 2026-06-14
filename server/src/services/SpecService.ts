import db from '../businessDatabase';
import {
  SpecNameDTO,
  SpecValueDTO,
  AttributeNameDTO,
  CategoryAttributeDTO,
  CategorySpecTreeDTO
} from '../models/Product';

export class SpecService {
  static createSpecName(name: string): SpecNameDTO {
    const now = Date.now();
    const maxSort = db.prepare('SELECT MAX(sort_order) as max_sort FROM spec_names').get() as { max_sort: number | null };
    const sortOrder = (maxSort?.max_sort ?? -1) + 1;

    db.prepare(`
      INSERT INTO spec_names (name, sort_order, created_at, updated_at) VALUES (?, ?, ?, ?)
    `).run(name, sortOrder, now, now);

    const id = (db.prepare('SELECT last_insert_rowid() as id').get() as { id: number }).id;
    return { id, name, sortOrder, createdAt: now, updatedAt: now };
  }

  static listSpecNames(): SpecNameDTO[] {
    const rows = db.prepare('SELECT * FROM spec_names ORDER BY sort_order ASC').all() as Record<string, unknown>[];
    return rows.map(r => ({
      id: r.id as number,
      name: r.name as string,
      sortOrder: r.sort_order as number,
      createdAt: r.created_at as number,
      updatedAt: r.updated_at as number
    }));
  }

  static createSpecValue(specNameId: number, value: string): SpecValueDTO {
    const now = Date.now();
    const maxSort = db.prepare('SELECT MAX(sort_order) as max_sort FROM spec_values WHERE spec_name_id = ?').get(specNameId) as { max_sort: number | null };
    const sortOrder = (maxSort?.max_sort ?? -1) + 1;

    db.prepare(`
      INSERT INTO spec_values (spec_name_id, value, sort_order, created_at, updated_at) VALUES (?, ?, ?, ?, ?)
    `).run(specNameId, value, sortOrder, now, now);

    const id = (db.prepare('SELECT last_insert_rowid() as id').get() as { id: number }).id;
    const specNameRow = db.prepare('SELECT name FROM spec_names WHERE id = ?').get(specNameId) as { name: string } | undefined;

    return {
      id,
      specNameId,
      specName: specNameRow?.name || '',
      value,
      sortOrder
    };
  }

  static listSpecValuesBySpecName(specNameId: number): SpecValueDTO[] {
    const rows = db.prepare(`
      SELECT sv.*, sn.name AS spec_name
      FROM spec_values sv
      JOIN spec_names sn ON sn.id = sv.spec_name_id
      WHERE sv.spec_name_id = ?
      ORDER BY sv.sort_order ASC
    `).all(specNameId) as Record<string, unknown>[];

    return rows.map(r => ({
      id: r.id as number,
      specNameId: r.spec_name_id as number,
      specName: r.spec_name as string,
      value: r.value as string,
      sortOrder: r.sort_order as number
    }));
  }

  static bindSpecNameToCategory(categoryId: number, specNameId: number): void {
    db.prepare(`
      INSERT OR IGNORE INTO category_spec_names (category_id, spec_name_id) VALUES (?, ?)
    `).run(categoryId, specNameId);
  }

  static getSpecNamesByCategory(categoryId: number): SpecNameDTO[] {
    const rows = db.prepare(`
      SELECT sn.*
      FROM category_spec_names csn
      JOIN spec_names sn ON sn.id = csn.spec_name_id
      WHERE csn.category_id = ?
      ORDER BY sn.sort_order ASC
    `).all(categoryId) as Record<string, unknown>[];

    return rows.map(r => ({
      id: r.id as number,
      name: r.name as string,
      sortOrder: r.sort_order as number,
      createdAt: r.created_at as number,
      updatedAt: r.updated_at as number
    }));
  }

  static createAttributeName(name: string, inputType: string): AttributeNameDTO {
    if (!['text', 'number', 'select'].includes(inputType)) {
      throw new Error('input_type 必须为 text/number/select');
    }

    const now = Date.now();
    const maxSort = db.prepare('SELECT MAX(sort_order) as max_sort FROM attribute_names').get() as { max_sort: number | null };
    const sortOrder = (maxSort?.max_sort ?? -1) + 1;

    db.prepare(`
      INSERT INTO attribute_names (name, input_type, sort_order, created_at, updated_at) VALUES (?, ?, ?, ?, ?)
    `).run(name, inputType, sortOrder, now, now);

    const id = (db.prepare('SELECT last_insert_rowid() as id').get() as { id: number }).id;
    return { id, name, inputType, sortOrder, createdAt: now, updatedAt: now };
  }

  static listAttributeNames(): AttributeNameDTO[] {
    const rows = db.prepare('SELECT * FROM attribute_names ORDER BY sort_order ASC').all() as Record<string, unknown>[];
    return rows.map(r => ({
      id: r.id as number,
      name: r.name as string,
      inputType: r.input_type as string,
      sortOrder: r.sort_order as number,
      createdAt: r.created_at as number,
      updatedAt: r.updated_at as number
    }));
  }

  static bindAttributeToCategory(categoryId: number, attributeNameId: number, isRequired: boolean): void {
    db.prepare(`
      INSERT OR IGNORE INTO category_attributes (category_id, attribute_name_id, is_required) VALUES (?, ?, ?)
    `).run(categoryId, attributeNameId, isRequired ? 1 : 0);
  }

  static getAttributesByCategory(categoryId: number): CategoryAttributeDTO[] {
    const rows = db.prepare(`
      SELECT ca.category_id, ca.attribute_name_id, an.name AS attribute_name, an.input_type, ca.is_required
      FROM category_attributes ca
      JOIN attribute_names an ON an.id = ca.attribute_name_id
      WHERE ca.category_id = ?
      ORDER BY an.sort_order ASC
    `).all(categoryId) as { category_id: number; attribute_name_id: number; attribute_name: string; input_type: string; is_required: number }[];

    return rows.map(r => ({
      categoryId: r.category_id,
      attributeNameId: r.attribute_name_id,
      attributeName: r.attribute_name,
      inputType: r.input_type,
      isRequired: r.is_required === 1
    }));
  }

  static getCategorySpecTree(categoryId: number): CategorySpecTreeDTO[] {
    const specNames = SpecService.getSpecNamesByCategory(categoryId);

    return specNames.map(sn => {
      const values = SpecService.listSpecValuesBySpecName(sn.id);
      return {
        specNameId: sn.id,
        specName: sn.name,
        values
      };
    });
  }
}