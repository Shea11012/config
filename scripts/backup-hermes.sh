#!/bin/bash
# backup-hermes.sh — 备份 & 还原 Hermes + OpenViking 数据
#
# 备份（Hermes cronjob 自动触发）:
#   bash backup-hermes.sh
#
# 还原（在任何机器上手动执行）:
#   bash backup-hermes.sh restore <备份文件.tar.gz> [--home /home/xxx] [--force]
#
# 选项:
#   --home    指定目标 home 目录（默认 $HOME）
#   --force   覆盖已有文件不询问
#   --dry-run 仅列出将要还原的内容，不实际执行

set -euo pipefail

BACKUP_ROOT="$HOME/Documents/backups"
KEEP_COUNT=7
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/hermes-backup-$TIMESTAMP"
TARBALL="$BACKUP_ROOT/hermes-backup-$TIMESTAMP.tar.gz"

# ─── 备份源清单 ──────────────────────────────────
# 格式: "标签|源路径"
# Hermes 的 state.db 不走 cp，用 sqlite3 .backup 快照
SOURCES=(
    "hermes-config|$HOME/.hermes/config.yaml"
    "hermes-env|$HOME/.hermes/.env"
    "hermes-soul|$HOME/.hermes/SOUL.md"
    "hermes-skills|$HOME/.hermes/skills"
    "hermes-sessions|$HOME/.hermes/sessions"
    "hermes-memories|$HOME/.hermes/memories"
    "hermes-themes|$HOME/.hermes/dashboard-themes"
    "hermes-profiles|$HOME/.hermes/profiles"
    "hermes-state|$HOME/.hermes/state.db"
    "openviking|$HOME/workspace/mxy/config/image-tools/data/openviking"
)

log()  { echo "[$(date '+%H:%M:%S')] $*"; }
warn() { echo "[$(date '+%H:%M:%S')] ⚠  $*" >&2; }
err()  { echo "[$(date '+%H:%M:%S')] ❌ $*" >&2; }
ok()   { echo "[$(date '+%H:%M:%S')] ✅ $*"; }

# ═══════════════════════════════════════════════════
# 备份
# ═══════════════════════════════════════════════════
do_backup() {
    log "开始备份 → $BACKUP_DIR"
    mkdir -p "$BACKUP_ROOT" "$BACKUP_DIR"

    local copied=0 skipped=0

    for src in "${SOURCES[@]}"; do
        local label="${src%%|*}"
        local path="${src#*|}"

        if    [[ "$label" == "hermes-state" ]]; then
            if [[ -f "$path" ]]; then
                sqlite3 "$path" ".backup '$BACKUP_DIR/state.db'"
                ok "state.db — sqlite3 快照"
                ((copied++))
            else
                warn "state.db 不存在: $path"
                ((skipped++))
            fi

        elif  [[ -e "$path" ]]; then
            local dest="$BACKUP_DIR/${label#hermes-}"
            [[ "$label" == hermes-* ]] && dest="$BACKUP_DIR/hermes/${label#hermes-}"
            mkdir -p "$(dirname "$dest")"
            cp -a "$path" "$dest"
            ok "${label}"
            copied=$((copied + 1))
        else
            warn "源不存在，跳过: $path"
            skipped=$((skipped + 1))
        fi
    done

    # 写入还原指引
    cat > "$BACKUP_DIR/RESTORE.txt" <<'EOF'
还原命令:
  bash backup-hermes.sh restore <本目录的 .tar.gz>

如果还原到另一台机器（$HOME 不同）:
  bash backup-hermes.sh restore <xxx.tar.gz> --home /home/newuser

注意事项:
  - 还原前请先关闭 Hermes Desktop
  - 还原后 state.db 等配置会被覆盖
  - OpenViking 数据仅在目标路径存在时才会还原
EOF

    # 打包
    log "打包 → $TARBALL"
    tar -czf "$TARBALL" -C "$BACKUP_DIR" .

    # 清理临时目录
    rm -rf "$BACKUP_DIR"

    # 清理旧备份
    local old
    old=$(ls -1t "$BACKUP_ROOT"/hermes-backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_COUNT+1)))
    if [[ -n "$old" ]]; then
        echo "$old" | xargs rm -f
        log "清理旧备份: $(echo "$old" | wc -l) 个"
    fi

    local size
    size=$(du -h "$TARBALL" | cut -f1)
    ok "备份完成 — $TARBALL ($size) — 保留最近 $KEEP_COUNT 个"
}

# ═══════════════════════════════════════════════════
# 还原
# ═══════════════════════════════════════════════════
do_restore() {
    local tarball="$1"
    local target_home="${HOME}"
    local force=false
    local dry_run=false

    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --home)   target_home="$2"; shift 2 ;;
            --force)  force=true; shift ;;
            --dry-run) dry_run=true; shift ;;
            *) err "未知参数: $1"; exit 1 ;;
        esac
    done

    if [[ ! -f "$tarball" ]]; then
        err "备份文件不存在: $tarball"
        exit 1
    fi

    log "还原目标 home: $target_home"

    local tmpdir
    tmpdir=$(mktemp -d /tmp/hermes-restore.XXXXXXX)
    trap "rm -rf $tmpdir" EXIT

    tar -xzf "$tarball" -C "$tmpdir"
    log "备份已解压到临时目录"

    # Hermes 配置
    local hermes_home="$target_home/.hermes"

    if $dry_run; then
        log "=== DRY RUN — 不实际写入 ==="
        find "$tmpdir" -not -name 'RESTORE.txt' -type f -o -type d | sort | while read f; do
            echo "  → ${f/$tmpdir/$hermes_home}"
        done
        exit 0
    fi

    # 检查冲突
    if [[ -d "$hermes_home" ]] && ! $force; then
        warn "目标 ~/.hermes 已存在，将覆盖以下内容:"
        find "$tmpdir/hermes" -type f 2>/dev/null | head -10
        echo ""
        read -rp "确认覆盖? [y/N] " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || { log "已取消"; exit 0; }
    fi

    local restored=0 skipped=0

    # 还原 Hermes 文件
    if [[ -d "$tmpdir/hermes" ]]; then
        mkdir -p "$hermes_home"
        cp -a "$tmpdir/hermes/"* "$hermes_home/"
        ok "Hermes 配置已还原"
        ((restored++))
    fi

    # 还原 config.yaml / .env / SOUL.md（顶层文件）
    for f in config.yaml .env SOUL.md state.db; do
        if [[ -f "$tmpdir/$f" ]]; then
            cp -a "$tmpdir/$f" "$hermes_home/$f"
            ok "$f"
            ((restored++))
        fi
    done

    # OpenViking
    local viking_src="$tmpdir/openviking"
    local viking_dst="$target_home/workspace/mxy/config/image-tools/data/openviking"

    if [[ -d "$viking_src" ]]; then
        if [[ -d "$(dirname "$viking_dst")" ]]; then
            mkdir -p "$viking_dst"
            cp -a "$viking_src/"* "$viking_dst/"
            ok "OpenViking 数据已还原 → $viking_dst"
            ((restored++))
        else
            warn "OpenViking 目标路径不存在，跳过 → $(dirname "$viking_dst")"
            warn "请先创建目录后再手动解压: tar -xzf $tarball openviking -C <正确的路径>"
            ((skipped++))
        fi
    else
        warn "备份中没有 OpenViking 数据（可能备份时源目录不存在）"
        ((skipped++))
    fi

    echo ""
    log "还原完成 — 成功: $restored, 跳过: $skipped"
}

# ═══════════════════════════════════════════════════
# 入口
# ═══════════════════════════════════════════════════
case "${1:-}" in
    restore)
        shift
        if [[ $# -eq 0 ]]; then
            echo "用法: $0 restore <备份文件.tar.gz> [--home /path] [--force] [--dry-run]"
            exit 1
        fi
        do_restore "$@"
        ;;
    *)
        do_backup
        ;;
esac
