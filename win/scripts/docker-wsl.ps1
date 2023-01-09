$wslip = wsl -- ip -o -4 -json addr list eth0 | ConvertFrom-Json | %{ $_.addr_info.local } | ?{ $_ }
if($wslip -eq $null){
    echo "wslip is empty"
    return
}

Write-Host "Setting Docker context 'wsl' to host=tcp://$($wslip):2376"
$command=docker context inspect wsl | Out-Null
if($? -eq $false) {
    echo "create docker context wsl"
    docker context create wsl --docker "host=tcp://$($wslip):2376"
} else {
    docker context update wsl --docker "host=tcp://$($wslip):2376"
}

docker context use wsl