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
# 默认的dns查询服务器
  nameserver:
  - 192.168.32.1
  - https://dns.alidns.com/dns-query
  - https://doh.pub/dns-query
# 用作解析域名dns服务器
  default-nameserver:
  - 114.114.114.114
  - 223.5.5.5
# dns查询失败后的fallback，确保dns正确
  fallback:
  - https://dns.google/dns-query
  - https://1.1.1.1/dns-query
  nameserver-policy:
    'geosite:cn': [192.168.32.1,https://doh.pub/dns-query,https://dns.alidns.com/dns-query]
    'rules-set:proxy,proxy_domain': [https://8.8.8.8/dns-query,https://1.1.1.1/dns-query]
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
tun:
  enable: true
  stack: system
  device: utun
  mtu: 65535
  auto-route: true
  auto-detect-interface: true
  dns-hijack:
  - tcp://any:53
profile:
  store-selected: true
  store-fake-ip: true
rules:
# 过滤广告
- RULE-SET,adLite,REJECT
- RULE-SET,adLite-domain,REJECT

# DIRECT
- RULE-SET,custom-direct,DIRECT
- RULE-SET,steam-cn,DIRECT
- RULE-SET,netbease,DIRECT
- RULE-SET,china_max,DIRECT
- RULE-SET,china_domain,DIRECT
- RULE-SET,china_ip,DIRECT,no-resolve
- RULE-SET,apple,DIRECT
- RULE-SET,lan,DIRECT

# PROXY
- RULE-SET,openai,chatgpt
- RULE-SET,steam,节点选择
- RULE-SET,proxy,节点选择
- RULE-SET,proxy_domain,节点选择
- RULE-SET,apple_proxy,节点选择

# FINAL
- MATCH,节点选择

rule-providers:
  custom-direct:
    type: http
    behavior: classical
    path: "./rule_provider/custom-direct.yaml"
    url: "https://raw.githubusercontent.com/Shea11012/config/main/rules/clash-rules/direct.yaml"
    interval: 86400
  adLite:
    type: http
    behavior: classical
    path: "./rule_provider/adLite.yaml"
    url: "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/AdvertisingLite/AdvertisingLite.yaml"
    interval: 86400
  adLite-domain:
    type: http
    behavior: domain
    path: "./rule_provider/adLite-domain.yaml"
    url: "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/AdvertisingLite/AdvertisingLite_Domain.yaml"
    interval: 86400
  steam-cn:
    type: http
    behavior: classical
    path: "./rule_provider/steam-cn.yaml"
    url: "https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Clash/SteamCN/SteamCN.yaml"
    interval: 86400
  steam:
    type: http
    behavior: classical
    path: "./rule_provider/steam.yaml"
    url: "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/Steam/Steam.yaml"
    interval: 86400
  openai:
    type: http
    behavior: classical
    path: "./rule_provider/openai.yaml"
    url: "https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Clash/OpenAI/OpenAI.yaml"
    interval: 86400
  apple:
    type: http
    behavior: classical
    path: "./rule_provider/apple.yaml"
    url: "https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Clash/Apple/Apple.yaml"
    interval: 86400
  apple_proxy:
    type: http
    behavior: classical
    path: "./rule_provider/apple_proxy.yaml"
    url: "https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Clash/AppleProxy/AppleProxy.yaml"
    interval: 86400
  china_max:
    type: http
    behavior: classical
    path: "./rule_provider/china_max.yaml"
    url: "https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Clash/ChinaMax/ChinaMax.yaml"
    interval: 86400
  china_domain:
    type: http
    behavior: domain
    path: "./rule_provider/china_domain.txt"
    url: "https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Clash/ChinaMax/ChinaMax_Domain_For_Clash.txt"
    interval: 86400
  china_ip:
    type: http
    behavior: ipcidr
    path: "./rule_provider/china_ip.yaml"
    url: "https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Clash/ChinaMax/ChinaMax_IP_No_IPv6.yaml"
    interval: 86400
  proxy:
    type: http
    behavior: classical
    path: "./rule_provider/proxy.yaml"
    url: "https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Clash/Proxy/Proxy.yaml"
    interval: 86400
  proxy_domain:
    type: http
    behavior: domain
    path: "./rule_provider/proxy_domain.txt"
    url: "https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Clash/Proxy/Proxy_Domain_For_Clash.txt"
    interval: 86400
  lan:
    type: http
    behavior: classical
    path: "./rule_provider/lan.yaml"
    url: "https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Clash/Lan/Lan.yaml"
    interval: 86400
  netbease:
    type: http
    behavior: classical
    path: "./rule_provider/netbease.yaml"
    url: "https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Clash/NetEase/NetEase.yaml"
    interval: 86400