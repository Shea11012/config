set windows-shell := ["C:/Program Files/Git/bin/bash.exe", "-uc"]
set dotenv-load

host := "http://192.168.32.100:9090"

rsync := if os() == "windows" { "rsync -e /d/scoop/apps/cwrsync/current/bin/ssh.exe" } else { "rsync" }

sync-clash-rules: replace-config
  @{{rsync}} -av --no-perms --no-owner --no-group --files-from=./clash/filelist.txt ./clash openwrt:utils/caddy/assets/
  @echo "更新规则"
  @xh -q PUT {{host}}/providers/rules/custom-proxy
  @rm clash/config.yaml

replace-config:
  @sed -e "s|\$baiyueguang|${BAIYUEGUANG}|g" -e "s|\$sanyueqi|${SANYUEQI}|g" -e "s|\$enet|${ENET}|g" clash/config.tp.yaml > clash/config.yaml

update-clash-meta-ui:
  @xh POST {{host}}/upgrade/ui
  
test:
  @{{rsync}} -av --no-perms --no-owner --no-group --files-from=./clash/filelist.txt ./clash openwrt:utils/caddy/assets/
  # echo $SHELL
  # which ssh
  # which rsync
  