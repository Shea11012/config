def update_docker_context [] {
    let wsl_ip: string = (wsl -- ip -o -4 -json addr show eth0 | from json | get addr_info | flatten | get local.0)
    if $wsl_ip == "" {
        echo "wsl ip is empty"
        return
    }
    
    # 使用 char --unicode 0a 的方式才能分割空白字符串，也可以使用lines进行分割
    if "wsl" in (docker context ls -q | split row (char --unicode 0a)) {
        echo "update docker context wsl"
        docker context update wsl --docker $"host=tcp://($wsl_ip):2376"
    } else {
        echo "create docker context wsl"
        docker context create wsl --docker $"host=tcp://($wsl_ip):2376"
    }

    docker context use wsl
}

alias rsync = ^rsync -e D:/scoop/apps/cwrsync/current/bin/ssh.exe
