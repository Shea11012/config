port: 7890
socks-port: 7891
allow-lan: true
mode: rule
log-level: info
external-controller: 0.0.0.0:9090
dns:
  enable: true
  ipv6: false
  listen: 0.0.0.0:7874
  enhanced-mode: fake-ip
  default-nameserver:
  - 119.29.29.29
  - 119.28.28.28
  - 1.0.0.1
  - 208.67.222.222
  - 1.2.4.8
  nameserver:
  - 114.114.114.114
  - 119.29.29.29
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
  - "*.lan"
  - "*.localdomain"
  - "*.example"
  - "*.invalid"
  - "*.localhost"
  - "*.test"
  - "*.local"
  - "*.home.arpa"
  - time.*.com
  - time.*.gov
  - time.*.edu.cn
  - time.*.apple.com
  - time-ios.apple.com
  - time1.*.com
  - time2.*.com
  - time3.*.com
  - time4.*.com
  - time5.*.com
  - time6.*.com
  - time7.*.com
  - ntp.*.com
  - ntp1.*.com
  - ntp2.*.com
  - ntp3.*.com
  - ntp4.*.com
  - ntp5.*.com
  - ntp6.*.com
  - ntp7.*.com
  - "*.time.edu.cn"
  - "*.ntp.org.cn"
  - "+.pool.ntp.org"
  - time1.cloud.tencent.com
  - music.163.com
  - "*.music.163.com"
  - "*.126.net"
  - musicapi.taihe.com
  - music.taihe.com
  - songsearch.kugou.com
  - trackercdn.kugou.com
  - "*.kuwo.cn"
  - api-jooxtt.sanook.com
  - api.joox.com
  - joox.com
  - y.qq.com
  - "*.y.qq.com"
  - streamoc.music.tc.qq.com
  - mobileoc.music.tc.qq.com
  - isure.stream.qqmusic.qq.com
  - dl.stream.qqmusic.qq.com
  - aqqmusic.tc.qq.com
  - amobile.music.tc.qq.com
  - "*.xiami.com"
  - "*.music.migu.cn"
  - music.migu.cn
  - "+.msftconnecttest.com"
  - "+.msftncsi.com"
  - localhost.ptlogin2.qq.com
  - localhost.sec.qq.com
  - "+.qq.com"
  - "+.tencent.com"
  - "+.srv.nintendo.net"
  - "*.n.n.srv.nintendo.net"
  - "+.stun.playstation.net"
  - xbox.*.*.microsoft.com
  - "*.*.xboxlive.com"
  - xbox.*.microsoft.com
  - xnotify.xboxlive.com
  - "+.battlenet.com.cn"
  - "+.wotgame.cn"
  - "+.wggames.cn"
  - "+.wowsgame.cn"
  - "+.wargaming.net"
  - proxy.golang.org
  - stun.*.*
  - stun.*.*.*
  - "+.stun.*.*"
  - "+.stun.*.*.*"
  - "+.stun.*.*.*.*"
  - "+.stun.*.*.*.*.*"
  - heartbeat.belkin.com
  - "*.linksys.com"
  - "*.linksyssmartwifi.com"
  - "*.router.asus.com"
  - mesu.apple.com
  - swscan.apple.com
  - swquery.apple.com
  - swdownload.apple.com
  - swcdn.apple.com
  - swdist.apple.com
  - lens.l.google.com
  - stun.l.google.com
  - "+.nflxvideo.net"
  - "*.square-enix.com"
  - "*.finalfantasyxiv.com"
  - "*.ffxiv.com"
  - "*.ff14.sdo.com"
  - ff.dorado.sdo.com
  - "*.mcdn.bilivideo.cn"
  - "+.media.dssott.com"
  - shark007.net
  - Mijia Cloud
  - "+.cmbchina.com"
  - "+.cmbimg.com"
  - local.adguard.org
  - "+.sandai.net"
  - "+.n0808.com"

{% if local.clash.new_field_name == "true" %}
proxies: ~
proxy-groups: ~
rules: ~
{% else %}
Proxy: ~
Proxy Group: ~
Rule: ~
{% endif %}

redir-port: 7892
tproxy-port: 7895
mixed-port: 7893
secret: ''
bind-address: "*"
external-ui: "/usr/share/openclash/ui"
ipv6: false
geodata-mode: true
geodata-loader: memconservative
tcp-concurrent: true
find-process-mode: 'off'
sniffer:
  enable: true
  ForceDnsMapping: false
  ParsePureIp: true
  force-domain:
  - "+.netflix.com"
  - "+.nflxvideo.net"
  - "+.amazonaws.com"
  - "+.media.dssott.com"
  skip-domain:
  - "+.apple.com"
  - Mijia Cloud
  - "+.jd.com"
  sniff:
    TLS:
    HTTP:
      ports:
      - 80
      - 8080-8880
      override-destination: true
tun:
  enable: true
  stack: system
  device: utun
  mtu: 65535
  auto-route: false
  auto-detect-interface: false
  dns-hijack:
  - tcp://any:53
profile:
  store-selected: true
  store-fake-ip: true
rule-providers:
  steam-direct:
    type: http
    behavior: classical
    path: "./rule_provider/steam.yaml"
    url: "https://raw.githubusercontent.com/Shea11012/config/main/clash-rules/steam.txt"
    interval: 86400
  private-direct:
    type: http
    behavior: domain
    path: "./rule_provider/private-direct.yaml"
    url: https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/private.txt
    interval: 86400
  reject:
    type: http
    behavior: domain
    path: "./rule_provider/reject.yaml"
    url: https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/reject.txt
    interval: 86400
  direct:
    type: http
    behavior: domain
    path: "./rule_provider/direct.yaml"
    url: https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/direct.txt
    interval: 86400
  iCloud:
    type: http
    behavior: domain
    path: "./rule_provider/iCloud.yaml"
    url: https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/icloud.txt
    interval: 86400
  apple:
    type: http
    behavior: domain
    path: "./rule_provider/apple.yaml"
    url: https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/apple.txt
    interval: 86400
  lancidr:
    type: http
    behavior: ipcidr
    path: "./rule_provider/lancidr.yaml"
    url: https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/lancidr.txt
    interval: 86400
  cncidr:
    type: http
    behavior: ipcidr
    path: "./rule_provider/cncidr.yaml"
    url: https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/cncidr.txt
    interval: 86400
  telegramcidr:
    type: http
    behavior: ipcidr
    path: "./rule_provider/telegramcidr.yaml"
    url: https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/telegramcidr.txt
    interval: 86400
  proxy:
    type: http
    behavior: domain
    path: "./rule_provider/proxy.yaml"
    url: https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/proxy.txt
    interval: 86400