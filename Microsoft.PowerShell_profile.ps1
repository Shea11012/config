oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/star.omp.json" | Invoke-Expression

Invoke-Expression (&sfsu hook)

$env:GOBREW_REGISTRY = "https://golang.google.cn/dl/"
$env:RUSTUP_DIST_SERVER = "https://rsproxy.cn"
$env:RUSTUP_UPDATE_ROOT = "https://rsproxy.cn/rustup"

# $a = @("rm", "del", "dir", "cat", "pwd", "mv", "ls", "kill")
# Remove-Alias -Name $a

function Get-ls {
    if ($args[0] -eq "") {
        lsd -l
    }
    else {
        lsd -l $args
    }
}

function Get-lt($n = 2) {
    lsd --tree --depth $n
}
Set-Alias -Name ls -Value lsd
Set-Alias -Name ll -Value Get-ls
Set-Alias -Name lt -Value Get-lt
Set-Alias -Name make -Value just
Set-Alias -Name rsync -Value customRsync

function customRsync {
    & rsync.exe -e 'D:/scoop/apps/cwrsync/current/bin/ssh.exe' @args
}

Invoke-Expression "$(zoxide init powershell)"
Invoke-Expression "$(vfox activate pwsh)"
