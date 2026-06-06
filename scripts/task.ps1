# 注册rclone task
sudo schtasks /create /tn "rclone" /tr "powershell.exe -WindowStyle hidden -ExecutionPolicy ByPass -WindowStyle Hidden -File C:\Users\18723\workspace\mxy\dotfiles\scripts\rclone.ps1"  /sc onlogon /f

# 删除 rclone task
sudo schtasks /Delete /tn "rclone"