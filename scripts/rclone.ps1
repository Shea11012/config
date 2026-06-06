# schtasks /create /tn "rclone" /tr "powershell.exe -WindowStyle hidden -Command rclone mount alist: Z: --cache-dir D:\alist-cache --vfs-cache-mode writes --local-no-sparse"  /sc onlogon /f

$targetDir = "D:\alist-cache"
$logFile = $targetDir + "\rclone.log"

if (Test-Path -Path $logFile) {
    Remove-Item $logFile
}

if (-not (Test-Path -Path $targetDir -PathType Container)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

rclone mount alist: Z: `
    --attr-timeout 1h `
    --buffer-size 128M `
    --dir-cache-time 10m `
    --poll-interval 1m `
    --vfs-cache-mode full `
    --vfs-cache-max-age 12h `
    --vfs-cache-max-size 100G `
    --vfs-cache-min-free-space 1G `
    --vfs-fast-fingerprint `
    --vfs-read-ahead 512M `
    --vfs-refresh `
    --transfers 16 `
    --checkers 16 `
    --multi-thread-streams 8 `
    --volname "Alist-WebDav" `
    --cache-dir $targetDir `
    --log-level INFO `
    --log-file $logFile `
    # --allow-other
