#!/bin/bash
# 备份和复原 openlist / openviking 数据
# 用法:
#   ./backup.sh backup  [备份目录]
#   ./backup.sh restore [备份目录]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SERVICES="openlist openviking"

usage() {
    echo "用法:"
    echo "  $0 backup  [备份目录]  # 备份数据"
    echo "  $0 restore [备份目录]  # 复原数据"
    exit 1
}

[ -z "$1" ] && usage

ACTION=$1
BACKUP_DIR="${2:-$HOME/backup/image-tools}"

stop_services() {
    echo "停止服务..."
    cd "$SCRIPT_DIR" && docker compose stop $SERVICES 2>/dev/null || true
}

start_services() {
    echo "启动服务..."
    cd "$SCRIPT_DIR" && docker compose start $SERVICES 2>/dev/null || true
}

backup() {
    local name=$1
    local src="$DATA_DIR/$name"
    local dst="$BACKUP_DIR/${name}_${TIMESTAMP}.tar.gz"

    if [ ! -d "$src" ]; then
        echo "跳过 $name: 源目录不存在"
        return
    fi

    echo "备份 $name..."
    sudo tar -czf "$dst" -C "$DATA_DIR" "$name" 2>/dev/null || \
    tar -czf "$dst" -C "$DATA_DIR" "$name"
    echo "  → $dst ($(du -h "$dst" | cut -f1))"
}

restore() {
    local name=$1
    local pattern="$BACKUP_DIR/${name}_*.tar.gz"
    local latest=$(ls -t $pattern 2>/dev/null | head -1)

    if [ -z "$latest" ]; then
        echo "跳过 $name: 未找到备份文件 ($BACKUP_DIR/${name}_*.tar.gz)"
        return
    fi

    local dst="$DATA_DIR/$name"
    local backup_existing="${dst}.bak.$(date +%Y%m%d_%H%M%S)"

    # 备份现有数据
    if [ -d "$dst" ]; then
        echo "  已有数据，备份到 $backup_existing"
        sudo mv "$dst" "$backup_existing" 2>/dev/null || mv "$dst" "$backup_existing"
    fi

    echo "复原 $name..."
    echo "  ← $latest"
    mkdir -p "$DATA_DIR"
    sudo tar -xzf "$latest" -C "$DATA_DIR" 2>/dev/null || \
    tar -xzf "$latest" -C "$DATA_DIR"

    # 修复权限
    sudo chown -R $(id -u):$(id -g) "$dst" 2>/dev/null || true
    echo "  完成"
}

case "$ACTION" in
    backup)
        mkdir -p "$BACKUP_DIR"
        stop_services
        backup "openlist"
        backup "openviking"
        start_services
        echo ""
        echo "备份完成: $BACKUP_DIR"
        ;;
    restore)
        if [ ! -d "$BACKUP_DIR" ]; then
            echo "错误: 备份目录不存在 $BACKUP_DIR"
            exit 1
        fi
        stop_services
        restore "openlist"
        restore "openviking"
        start_services
        echo ""
        echo "复原完成"
        ;;
    *)
        usage
        ;;
esac
