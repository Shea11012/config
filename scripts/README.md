# scripts/

个人运维脚本集，按场景分类。

## 备份 & 迁移

| 脚本 | 用途 | 用法 |
|------|------|------|
| `backup-hermes.sh` | Hermes + OpenViking 数据备份/还原 | cronjob 日备份；`restore <tar.gz>` 手动还原 |
| `docker-migrate.sh` | docker-compose 项目跨机器迁移 | `-t y7000p -c ./project`，自动导出镜像+volume+配置 |
| `koodo-backup.sh` | Koodo Reader 数据备份 | 对齐应用内 backupFromPath 逻辑，输出日期 zip |

## 同步

| 脚本 | 用途 | 用法 |
|------|------|------|
| `sync.sh` | jj 仓库同步到 rclone 远程 | `sync.sh <jj-repo-path>`，自动增量推送 |
| `rclone.sh` | rclone 挂载 OpenList（Linux） | 重试 + 健康检查，挂载到 `~/rclone/alist` |
| `rclone.ps1` | rclone 挂载 alist（Windows） | PowerShell，配合 `task.ps1` 注册计划任务 |
| `task.ps1` | Windows 计划任务注册/删除 | 注册 `rclone.ps1` 为登录自启任务 |

## 启动

| 脚本 | 用途 | 用法 |
|------|------|------|
| `start.sh` | 启动 image-tools 项目 | `cd` 到项目目录并执行 `just load` |

## Shell 工具函数

| 脚本 | Shell | 功能 |
|------|-------|------|
| `init.zsh` | zsh | `paru_update`（fzf 选包更新）、`paru_clean`（清理无用包）、`update_mirrors`（测速更新镜像源）、`lt`（lsd 树形显示） |
| `custom.nu` | nushell | `update_docker_context`（WSL 下更新 Docker context 指向 Windows 端） |

## 依赖

- `backup-hermes.sh`: tar, xz, ssh, OpenViking HTTP API（如果备份知识库内容）
- `docker-migrate.sh`: docker, rsync, jq, alpine 镜像（volume 导出用）
- `sync.sh`: jj, rclone
- `rclone.sh`: rclone
- `init.zsh`: paru, fzf, rate-mirrors, lsd
