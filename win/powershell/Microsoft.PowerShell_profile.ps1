$Env:http_proxy="http://127.0.0.1:7890";$Env:https_proxy="http://127.0.0.1:7890"

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/atomic.omp.json" | Invoke-Expression

sfst-hook | Invoke-Expression

$env:GOBREW_REGISTRY="https://golang.google.cn/dl/"
