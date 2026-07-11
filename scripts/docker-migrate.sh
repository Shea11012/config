#!/usr/bin/env bash
set -euo pipefail

# docker-migrate.sh — 将 docker-compose 项目从本机迁移到远程服务器
# 用法:
#   ./docker-migrate.sh -t <目标服务器> -c <compose目录>
#   ./docker-migrate.sh -e -c <compose目录>          # 仅导出
#   ./docker-migrate.sh -i -t <目标服务器> -c <compose目录>  # 仅导入

usage() {
  cat <<EOF
Usage: $(basename "$0") -t <target> -c <compose-dir> [options]

Options:
  -t, --target HOST      目标服务器 (SSH host)
  -c, --compose-dir DIR  docker-compose 项目目录 (必须)
  -r, --remote-dir DIR   远程目录 (默认同本地路径)
  -e, --export-only      仅导出到 /tmp/docker-migrate/
  -i, --import-only      仅从 /tmp/docker-migrate/ 导入 (需先传输)
  -n, --dry-run          只显示将要执行的操作，不实际执行
  -h, --help             显示帮助

示例:
  $(basename "$0") -t y7000p -c ~/workspace/mxy/config/image-tools
  $(basename "$0") -e -c ~/projects/myapp
  $(basename "$0") -i -t y7000p -c ~/projects/myapp
EOF
  exit 0
}

# --- 参数解析 ---
TARGET=""
COMPOSE_DIR=""
REMOTE_DIR=""
EXPORT_ONLY=false
IMPORT_ONLY=false
DRY_RUN=false
TMPDIR="/tmp/docker-migrate"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target) TARGET="$2"; shift 2 ;;
    -c|--compose-dir) COMPOSE_DIR="$2"; shift 2 ;;
    -r|--remote-dir) REMOTE_DIR="$2"; shift 2 ;;
    -e|--export-only) EXPORT_ONLY=true; shift ;;
    -i|--import-only) IMPORT_ONLY=true; shift ;;
    -n|--dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage ;;
    *) echo "未知参数: $1"; usage ;;
  esac
done

# 互斥检查
if $EXPORT_ONLY && $IMPORT_ONLY; then
  echo "错误: --export-only 和 --import-only 不能同时使用"
  exit 1
fi
if ! $EXPORT_ONLY && ! $IMPORT_ONLY && [[ -z "$TARGET" ]]; then
  echo "错误: 完整迁移需要 --target（或用 --export-only / --import-only）"
  exit 1
fi

COMPOSE_DIR="$(realpath "${COMPOSE_DIR}")"
COMPOSE_FILE="$COMPOSE_DIR/docker-compose.yaml"
if [[ ! -f "$COMPOSE_FILE" ]] && [[ ! -f "$COMPOSE_DIR/docker-compose.yml" ]]; then
  echo "错误: 目录 $COMPOSE_DIR 中没有找到 docker-compose.yaml/yml"
  exit 1
fi
# 统一使用 .yaml
if [[ -f "$COMPOSE_DIR/docker-compose.yaml" ]]; then
  COMPOSE_FILE="$COMPOSE_DIR/docker-compose.yaml"
else
  COMPOSE_FILE="$COMPOSE_DIR/docker-compose.yml"
fi

REMOTE_DIR="${REMOTE_DIR:-$COMPOSE_DIR}"
PROJECT_NAME="$(basename "$COMPOSE_DIR")"

log()  { echo "[$(date '+%H:%M:%S')] $*"; }
run()  {
  if $DRY_RUN; then echo "  [DRY] $*"; else eval "$@"; fi
}

# --- 导出阶段 ---
do_export() {
  log "=== 导出阶段 ==="
  run "rm -rf $TMPDIR && mkdir -p $TMPDIR"

  # 1. 获取该 compose 项目的容器列表
  local containers
  containers=$(docker compose -f "$COMPOSE_FILE" ps -q 2>/dev/null || true)
  if [[ -z "$containers" ]]; then
    echo "警告: compose 项目没有运行中的容器，尝试获取所有容器..."
    containers=$(docker compose -f "$COMPOSE_FILE" ps -aq 2>/dev/null || true)
  fi

  if [[ -z "$containers" ]]; then
    echo "警告: 未找到任何容器，将仅打包 compose 目录"
  fi

  # 2. 导出镜像（去重）
  log "导出容器镜像..."
  local -A exported_images
  for cid in $containers; do
    local img
    img=$(docker inspect --format '{{.Config.Image}}' "$cid" 2>/dev/null)
    if [[ -n "$img" ]] && [[ -z "${exported_images[$img]:-}" ]]; then
      local safe_name="${img//[:\/]/_}"
      log "  → $img"
      run "docker save '$img' -o $TMPDIR/image-${safe_name}.tar"
      exported_images[$img]=1
    fi
  done

  # 3. 导出 named volumes
  log "导出 named volumes..."
  local volumes
  volumes=$(docker compose -f "$COMPOSE_FILE" config --volumes 2>/dev/null | grep -oP '^\S+' | sort -u || true)

  # 也用 inspect 补充检测 compose config 未列出的 volume
  for cid in $containers; do
    local extra_vols
    extra_vols=$(docker inspect "$cid" 2>/dev/null \
      | jq -r '.[0].Mounts[]? | select(.Type=="volume") | .Name' 2>/dev/null || true)
    volumes=$(echo -e "${volumes}\n${extra_vols}" | sort -u | grep -v '^$')
  done

  for vol in $volumes; do
    # 跳过匿名 volume 前缀
    if [[ -z "$vol" ]]; then continue; fi
    log "  → $vol"
    run "docker run --rm -v '${vol}:/vol:ro' -v '$TMPDIR:/backup' alpine \
      sh -c 'tar czf /backup/vol-${vol}.tar.gz -C /vol .'"
  done

  # 4. 打包 compose 目录
  log "打包 compose 项目目录..."
  local parent_dir archive_name
  parent_dir="$(dirname "$COMPOSE_DIR")"
  archive_name="$PROJECT_NAME.tar.gz"
  run "tar czf '$TMPDIR/$archive_name' -C '$parent_dir' '$PROJECT_NAME'"

  # 5. 生成 manifest
  log "生成 manifest..."
  cat > "$TMPDIR/manifest.txt" <<MANIFEST
# docker-migrate manifest
# 生成时间: $(date -Iseconds)
# 来源主机: $(hostname)
# 项目名称: $PROJECT_NAME
# compose 目录: $COMPOSE_DIR
# 远程目录: $REMOTE_DIR

## 镜像
$(for cid in $containers; do
  docker inspect --format '{{.Config.Image}}' "$cid" 2>/dev/null
done | sort -u | while read img; do echo "  - $img"; done)

## Volumes
$(for vol in $volumes; do echo "  - $vol"; done)

## 容器（用于参考，不用于还原）
$(for cid in $containers; do
  docker inspect --format '  - {{.Name}}: {{.Config.Image}}' "$cid" 2>/dev/null | sed 's|^/||'
done)
MANIFEST

  # 6. 汇总
  log "导出完成: $TMPDIR"
  log "文件列表:"
  run "ls -lh $TMPDIR/"
  log "总大小: $(du -sh $TMPDIR/ | cut -f1)"
}

# --- 导入阶段 ---
do_import() {
  log "=== 导入阶段 ==="

  if [[ ! -d "$TMPDIR" ]]; then
    echo "错误: $TMPDIR 不存在，请先执行导出或传输文件"
    exit 1
  fi

  local manifest="$TMPDIR/manifest.txt"
  if [[ -f "$manifest" ]]; then
    log "manifest:"
    cat "$manifest"
  fi

  # 1. 解压 compose 项目
  local archive_name="$PROJECT_NAME.tar.gz"
  if [[ -f "$TMPDIR/$archive_name" ]]; then
    log "解压 compose 项目到 $(dirname "$REMOTE_DIR")..."
    run "mkdir -p '$(dirname "$REMOTE_DIR")'"
    run "tar xzf '$TMPDIR/$archive_name' -C '$(dirname "$REMOTE_DIR")'"
  else
    log "跳过: 未找到 $archive_name"
  fi

  # 2. 检查 docker
  if ! command -v docker &>/dev/null; then
    echo "错误: 远程未安装 docker"
    exit 1
  fi

  # 启动 docker daemon（如果需要）
  if ! docker info &>/dev/null 2>&1; then
    log "启动 docker daemon..."
    if systemctl is-active --quiet docker 2>/dev/null; then
      log "docker daemon already active (but user may need sudo)"
    else
      run "sudo systemctl start docker"
    fi
  fi

  # 确定 docker 命令前缀
  local dc
  if docker ps &>/dev/null 2>&1; then
    dc="docker"
  else
    dc="sudo docker"
    log "需要使用 sudo 执行 docker 命令"
  fi

  # 3. 导入镜像
  log "导入镜像..."
  for tarfile in "$TMPDIR"/image-*.tar; do
    [[ -f "$tarfile" ]] || continue
    log "  → $(basename "$tarfile")"
    run "$dc load -i '$tarfile'"
  done

  # 4. 导入 volumes
  log "导入 volumes..."
  for tarfile in "$TMPDIR"/vol-*.tar.gz; do
    [[ -f "$tarfile" ]] || continue
    local vol_name
    vol_name=$(basename "$tarfile" | sed 's/^vol-//; s/\.tar\.gz$//')
    log "  → $vol_name"
    run "$dc run --rm -v '${vol_name}:/vol' -v '$TMPDIR:/backup' alpine \
      sh -c 'tar xzf /backup/$(basename "$tarfile") -C /vol'"
  done

  # 5. 启动 compose
  log "启动 docker compose..."
  local compose_file="$REMOTE_DIR/docker-compose.yaml"
  if [[ ! -f "$compose_file" ]]; then
    compose_file="$REMOTE_DIR/docker-compose.yml"
  fi
  run "cd '$REMOTE_DIR' && $dc compose -f '$compose_file' up -d"

  # 6. 等待健康检查
  log "等待容器启动..."
  sleep 5
  run "$dc compose -f '$compose_file' ps"

  log "迁移完成"
}

# --- 主流程 ---
if $IMPORT_ONLY; then
  do_import
elif $EXPORT_ONLY; then
  do_export
else
  # 完整迁移: 导出 → 传输 → 远程导入
  do_export

  # 把脚本本身也复制过去，远程用 --import-only 执行
  cp "$0" "$TMPDIR/docker-migrate.sh"

  log "=== 传输阶段 ==="
  log "传输 $TMPDIR/ → $TARGET:$TMPDIR/"
  run "ssh '$TARGET' 'rm -rf $TMPDIR && mkdir -p $TMPDIR'"
  run "rsync -avP '$TMPDIR/' '$TARGET:$TMPDIR/'"

  log "在 $TARGET 上执行导入..."
  run "ssh '$TARGET' 'bash $TMPDIR/docker-migrate.sh --import-only -c $COMPOSE_DIR -r $REMOTE_DIR'"
fi
