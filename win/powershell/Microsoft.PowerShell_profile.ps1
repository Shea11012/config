oh-my-posh init pwsh --config "~\workspace\remote\config\win\terminal\mytheme.omp.json" | Invoke-Expression

Invoke-Expression (&sfsu hook)

$env:GOBREW_REGISTRY="https://golang.google.cn/dl/"

$a = @("rm","del","dir","cat","pwd","mv","ls","kill")
Remove-Alias -Name $a

function Get-ll {
    lsd -l
}

function Get-lt($n = 2){
    lsd --tree --depth $n
}

Set-Alias -Name ls -Value lsd
Set-Alias -Name ll -Value Get-ll
Set-Alias -Name lt -Value Get-lt

Invoke-Expression (& { (zoxide init powershell | Out-String) })

fnm env --use-on-cd | Out-String | Invoke-Expression