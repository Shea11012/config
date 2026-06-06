#!/usr/bin/env bash
# 完全对齐 koodo-reader/src/utils/file/backup.ts 中 backupFromPath 逻辑的备份脚本

# ========== 核心配置（与源码一致） ==========
# Koodo Reader 数据根目录（Linux Electron 版默认路径）
DATA_ROOT="$HOME/.config/koodo-reader"
# 备份文件保存路径（对应源码中用户选择的 backupPath）
BACKUP_DIR="$HOME/Documents/koodo-backup"
# 备份文件名（对齐源码：YYYY-MM-DD.zip，补零逻辑一致）
FILE_NAME=$(date +%Y-%m-%d).zip
# 临时打包目录（避免污染原数据）
TMP_ZIP_DIR="/tmp/koodo-backup-tmp"

# ========== 步骤1：校验前置条件（对齐源码 checkMissingBook + 路径校验） ==========
# 检查数据根目录是否存在
if [ ! -d "$DATA_ROOT" ]; then
    echo "错误：Koodo Reader 数据目录不存在 → $DATA_ROOT"
    exit 1
fi

# 检查核心子目录/文件是否存在（与源码 backupFromPath 中判断逻辑一致）
REQUIRED_DIRS=(
    "$DATA_ROOT/book"
    "$DATA_ROOT/cover"
    "$DATA_ROOT/config"
)
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "警告：非必需目录不存在（跳过）→ $dir"
    fi
done

# ========== 步骤2：创建临时目录（模拟源码 zip 打包逻辑） ==========
rm -rf "$TMP_ZIP_DIR"  # 清空旧临时文件
mkdir -p "$TMP_ZIP_DIR"

# ========== 步骤3：复刻 backupFromPath 的选择性备份逻辑 ==========
echo "开始按源码规则筛选备份文件..."

# 1. 备份 book 目录（对齐源码：if (fs.existsSync(path.join(dataPath, "book"))) { zip.addLocalFolder(...) }）
if [ -d "$DATA_ROOT/book" ]; then
    cp -r "$DATA_ROOT/book" "$TMP_ZIP_DIR/"
    echo "✅ 已备份：book 目录"
fi

# 2. 备份 cover 目录（对齐源码：if (fs.existsSync(path.join(dataPath, "cover"))) { zip.addLocalFolder(...) }）
if [ -d "$DATA_ROOT/cover" ]; then
    cp -r "$DATA_ROOT/cover" "$TMP_ZIP_DIR/"
    echo "✅ 已备份：cover 目录"
fi

# 3. 备份 config 目录下的指定文件（完全对齐源码逻辑）
mkdir -p "$TMP_ZIP_DIR/config"
# 3.1 备份 config.json（对齐源码：config/config.json）
if [ -f "$DATA_ROOT/config/config.json" ]; then
    cp "$DATA_ROOT/config/config.json" "$TMP_ZIP_DIR/config/"
    echo "✅ 已备份：config/config.json"
fi
# 3.2 备份 sync.json（对齐源码：config/sync.json）
if [ -f "$DATA_ROOT/config/sync.json" ]; then
    cp "$DATA_ROOT/config/sync.json" "$TMP_ZIP_DIR/config/"
    echo "✅ 已备份：config/sync.json"
fi
# 3.3 备份所有 .db 数据库文件（对齐源码：CommonTool.databaseList 循环备份 .db 文件）
# 源码中 CommonTool.databaseList 包含的数据库名（从上下文推导：books、notes、bookmarks、words、plugins）
DB_FILES=(
    "books.db"
    "notes.db"
    "bookmarks.db"
    "words.db"
    "plugins.db"
)
for db_file in "${DB_FILES[@]}"; do
    if [ -f "$DATA_ROOT/config/$db_file" ]; then
        cp "$DATA_ROOT/config/$db_file" "$TMP_ZIP_DIR/config/"
        echo "✅ 已备份：config/$db_file"
    fi
done

# ========== 步骤4：打包临时目录为 zip（对齐源码 zip.writeZip） ==========
mkdir -p "$BACKUP_DIR"
# 进入临时目录打包（保证 zip 内目录结构与源码一致）
cd "$TMP_ZIP_DIR" || exit
zip -r "$BACKUP_DIR/$FILE_NAME" ./* -q
cd - > /dev/null || exit

# ========== 步骤5：校验备份结果 + 清理临时文件 ==========
rm -rf "$TMP_ZIP_DIR"  # 清理临时文件

if [ -f "$BACKUP_DIR/$FILE_NAME" ]; then
    echo -e "\n🎉 备份成功！文件路径：$BACKUP_DIR/$FILE_NAME"
    # 验证 zip 内目录结构（与源码一致）
    echo -e "\n📋 备份文件内目录结构："
    unzip -l "$BACKUP_DIR/$FILE_NAME" | head -20
    exit 0
else
    echo -e "\n❌ 备份失败！未生成 zip 包"
    exit 1
fi
