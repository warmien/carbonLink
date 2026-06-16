#!/bin/sh
# CarbonLink 数据库初始化脚本
# 用法: sh scripts/init-db.sh

set -e

DB_DIR="./data"
DB_FILE="$DB_DIR/carbonlink.db"
ADMIN_DB_FILE="$DB_DIR/carbonlink_admin.db"
SQL_FILE="./scripts/init.sql"

echo "=== CarbonLink 数据库初始化 ==="

mkdir -p "$DB_DIR"

if [ -f "$DB_FILE" ]; then
    echo "[WARN] 业务数据库已存在: $DB_FILE"
    echo "  如需重建，请先删除: rm $DB_FILE"
else
    echo "[INFO] 创建业务数据库: $DB_FILE"
    sqlite3 "$DB_FILE" < "$SQL_FILE"
    echo "[OK] 业务数据库初始化完成"
fi

if [ -f "$ADMIN_DB_FILE" ]; then
    echo "[WARN] 管理数据库已存在: $ADMIN_DB_FILE"
else
    echo "[INFO] 管理数据库将在首次启动服务时自动创建"
fi

echo ""
echo "=== 数据库文件列表 ==="
ls -lh "$DB_DIR" 2>/dev/null || echo "  (空)"

echo ""
echo "=== 验证表结构 ==="
echo "--- carbonlink.db ---"
sqlite3 "$DB_FILE" ".tables"
echo ""
echo "users 表结构:"
sqlite3 "$DB_FILE" "PRAGMA table_info(users);"

echo ""
echo "[OK] 初始化完成"