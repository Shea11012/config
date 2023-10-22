oh-my-posh init pwsh --config "C:\Users\18723\workspace\remote\config\win\terminal\mytheme.omp.json" | Invoke-Expression

sfst-hook | Invoke-Expression

$env:GOBREW_REGISTRY="https://golang.google.cn/dl/"

$a = @("rm","del","dir","cat","pwd","mv","ls","kill")
Remove-Alias -Name $a

Set-Alias -Name ls -Value lsd

Invoke-Expression (& { (zoxide init powershell | Out-String) })
