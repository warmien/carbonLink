import Database from 'better-sqlite3';
import bcrypt from 'bcryptjs';
import { AdminRole, AdminStatus } from './models/AdminAccount';

const db = new Database('carbonlink_admin.db');

db.pragma('journal_mode = WAL');

db.exec(`
  CREATE TABLE IF NOT EXISTS admin_accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT '${AdminRole.SUPER_ADMIN}',
    status TEXT NOT NULL DEFAULT '${AdminStatus.ACTIVE}',
    lastLoginTime INTEGER,
    loginFailCount INTEGER DEFAULT 0,
    lockedUntil INTEGER
  );

  CREATE TABLE IF NOT EXISTS audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    adminId INTEGER NOT NULL,
    action TEXT NOT NULL,
    target TEXT DEFAULT '',
    timestamp INTEGER NOT NULL,
    detail TEXT DEFAULT ''
  );

  CREATE TABLE IF NOT EXISTS data_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reportType TEXT NOT NULL,
    timeRange TEXT NOT NULL,
    granularity TEXT NOT NULL,
    data TEXT NOT NULL,
    generatedAt INTEGER NOT NULL
  );
`);

const existingAdmin = db.prepare('SELECT id FROM admin_accounts WHERE username = ?').get('admin');
if (!existingAdmin) {
  const hashedPassword = bcrypt.hashSync('admin123', 10);
  db.prepare(
    `INSERT INTO admin_accounts (username, password, role, status) VALUES (?, ?, ?, ?)`
  ).run('admin', hashedPassword, AdminRole.SUPER_ADMIN, AdminStatus.ACTIVE);
}

export default db;