#!/usr/bin/env bash

OPENLIST_MOUNT_TARGET=/home/mxy/rclone/alist
OPENLIST_MOUNT_OPT=(--attr-timeout 1h --buffer-size 128M --dir-cache-time 24h --poll-interval 5m --vfs-cache-mode minimal --no-checksum --no-modtime --vfs-cache-max-size 100G --vfs-cache-max-age 12h --vfs-cache-min-free-space 1G --vfs-fast-fingerprint --vfs-read-ahead 512M --vfs-refresh --transfers 16 --checkers 16 --multi-thread-streams 8 --log-level INFO)

OPENLIST_REMOTE="alist"
OPENLIST_HOST=":5244"
#$1:count(重试次数)
#$2:fn(执行函数)
#$3...传递给fn的参数
_openlist_retry() {
	local count=$1
	local fn=$2
	shift 2

	local attempt=1
	local exit_code=0

	while [ $attempt -le "$count" ]; do
		echo "Attempt: $attempt of $count: $fn $@"

		# 尝试执行命令
		"$fn" "$@"
		exit_code=$?

		if [ $exit_code -eq 0 ]; then
			echo "success"
			return 0
		fi

		if [ $attempt -lt "$count" ]; then
			echo "command failed with $exit_code.Retrying in 1 second"
			sleep 1
		fi

		((attempt++))
	done

	echo "failed after $count attempt"
	return $exit_code
}

_openlist_isOnline() {
	local res=$(xh -b "$OPENLIST_HOST/ping")
	if [[ "$res" == "pong" ]]; then
		return 0
	fi

	return 1
}

openlist_mount() {
	if _openlist_retry 3 _openlist_isOnline; then
		rclone mount "$OPENLIST_REMOTE:" "$OPENLIST_MOUNT_TARGET" "${OPENLIST_MOUNT_OPT[@]}"
	fi
}

openlist_umount() {
	umount "$OPENLIST_MOUNT_TARGET"
}

openlist_mount
