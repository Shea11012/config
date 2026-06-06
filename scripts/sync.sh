#!/usr/bin/env bash
set -euo pipefail

# ========== 配置 ==========
REMOTE="myremote:"              # rclone 远程名（带冒号）
REMOTE_PATH="my-backup/project" # 远端仓库路径（末尾不要加 /）
SYNC_STATE_FILE=".jj-sync-last" # 记录上次同步提交的文件（相对于仓库根目录）
AUTO_COMMIT=true                # 同步后是否自动提交
# ==========================

# 解析参数：仓库路径
if [ $# -ne 1 ]; then
    echo "用法: $0 <jj-仓库路径>"
    exit 1
fi

REPO_PATH="$1"

# 规范化路径并验证
REPO_PATH=$(cd "$REPO_PATH" 2>/dev/null && pwd) || {
    echo "错误：路径不存在或无法访问: $1"
    exit 1
}

# 确保是 jj 仓库（可选但推荐）
if [ ! -d "$REPO_PATH/.jj" ]; then
    echo "警告：路径 $REPO_PATH 没有 .jj 目录，可能不是 jj 仓库"
    # 不强制退出，允许尝试运行，但后续 jj 命令会失败
fi

# 所有后续操作都基于仓库路径
cd "$REPO_PATH"

# 锚点文件路径
SYNC_STATE_PATH="$REPO_PATH/$SYNC_STATE_FILE"

# 读取上次同步的起点
if [ -f "$SYNC_STATE_PATH" ]; then
    LAST_COMMIT=$(cat "$SYNC_STATE_PATH")
else
    LAST_COMMIT=$(jj log -r 'root()' --no-graph -T 'commit_id' 2>/dev/null)
    if [ -z "$LAST_COMMIT" ]; then
        echo "无法确定起始提交，请手动创建 $SYNC_STATE_PATH 并写入一个 commit ID"
        exit 1
    fi
fi

CURRENT_COMMIT="@"
echo "📌 仓库: $REPO_PATH"
echo "📌 上次同步: $LAST_COMMIT"
echo "📌 当前提交: $CURRENT_COMMIT"

# 获取变更摘要
SUMMARY=$(jj diff --from "$LAST_COMMIT" --to "$CURRENT_COMMIT" --summary 2>&1)
if [ -z "$SUMMARY" ]; then
    echo "✅ 没有变更，无需同步。"
    jj log -r "$CURRENT_COMMIT" --no-graph -T 'commit_id' >"$SYNC_STATE_PATH"
    exit 0
fi

# 分类建立 copy / delete 临时文件列表
COPY_LIST=$(mktemp)
DELETE_LIST=$(mktemp)
trap 'rm -f "$COPY_LIST" "$DELETE_LIST"' EXIT

while IFS= read -r line; do
    status="${line:0:1}"
    file="${line:2}"
    [ -z "$file" ] && continue

    case "$status" in
    M | A) printf '%s\n' "$file" >>"$COPY_LIST" ;;
    D) printf '%s\n' "$file" >>"$DELETE_LIST" ;;
    *) echo "⚠ 忽略未知状态: $line" ;;
    esac
done <<<"$SUMMARY"

# 预览操作
echo ""
if [ -s "$COPY_LIST" ]; then
    echo "📤 将上传 / 覆盖远端以下文件："
    cat "$COPY_LIST" | sed 's/^/  /'
fi
if [ -s "$DELETE_LIST" ]; then
    echo "🗑  将删除远端以下文件："
    cat "$DELETE_LIST" | sed 's/^/  /'
fi
echo ""

# 执行 rclone 操作
EXIT_CODE=0

if [ -s "$COPY_LIST" ]; then
    echo "⏳ 开始上传..."
    rclone copy --files-from "$COPY_LIST" . "${REMOTE}${REMOTE_PATH}" --progress || EXIT_CODE=1
fi

if [ -s "$DELETE_LIST" ]; then
    echo "⏳ 开始删除远端文件..."
    xargs -d '\n' -a "$DELETE_LIST" rclone deletefile "${REMOTE}${REMOTE_PATH}"/{} --progress || EXIT_CODE=1
fi

if [ $EXIT_CODE -ne 0 ]; then
    echo "❌ rclone 操作失败，停止。"
    exit 1
fi

# 同步成功 → 自动提交
if [ "$AUTO_COMMIT" = true ]; then
    if jj diff --summary | grep -q .; then
        echo "📝 自动提交当前变更..."
        jj commit -m "sync: $(date -u +%Y-%m-%dT%H:%M:%SZ)" || {
            echo "自动提交失败，请手动检查 jj 状态。"
            exit 1
        }
    fi
fi

# 更新锚点
jj log -r @ --no-graph -T 'commit_id' >"$SYNC_STATE_PATH"
echo "✅ 同步完成，锚点已更新为 $(cat "$SYNC_STATE_PATH")。"
