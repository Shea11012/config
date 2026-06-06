/*
- full: 启用完整配置，用于纯内核启动(默认false)
 - loadbalance: 负载均衡
 */

const inArg = typeof $arguments !== "undefined" ? $arguments : {};
const full = parseBool(inArg.full) || false;
const loadBalance = parseBool(inArg.loadbalance) || false;

const defaultRuleProvider = (url, behavior) => {
  return {
    type: "http",
    interval: 86400,
    url,
    behavior,
    format: "mrs",
  };
};

const domainRuleProvider = (url) => defaultRuleProvider(url, "domain");
const ipRuleProvider = (url) => defaultRuleProvider(url, "ipcidr");

const ruleProviders = {
  "custom-proxy": {
    ...domainRuleProvider(
      "http://arch.local/assets/dotfiles/clash/custom_proxy.yaml",
    ),
    format: "yaml",
  },
  adrules_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/adrules.mrs",
  ),
  adrules_ip: ipRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/ipcidr/adrules.mrs",
  ),
  Ai_Domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/ai.mrs",
  ),
  tld_proxy_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/tld-proxy.mrs",
  ),
  fake_ip_filter_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/fake-ip-filter.mrs",
  ),
  proxy_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/proxy.mrs",
  ),
  proxy_ip: ipRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/ipcidr/proxy.mrs",
  ),
  cn_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/cn.mrs",
  ),
  cn_ip: ipRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/ipcidr/cn.mrs",
  ),
  games_cn_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/games-cn.mrs",
  ),
  socialmedia_cn_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/socialmedia-cn.mrs",
  ),
  socialmedia_cn_ip: ipRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/ipcidr/socialmedia-cn.mrs",
  ),
  httpdns_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/httpdns.mrs",
  ),
  httpdns_ip: ipRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/ipcidr/httpdns.mrs",
  ),
  gits_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/gits.mrs",
  ),
  cdn_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/cdn.mrs",
  ),
  private_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/private.mrs",
  ),
  private_ip: ipRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/ipcidr/private.mrs",
  ),
  microsoft_cn_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/microsoft-cn.mrs",
  ),
  tiktok_domain: domainRuleProvider(
    "https://raw.githubusercontent.com/QuixoticHeart/rule-set/ruleset/meta/domain/tiktok.mrs",
  ),
};

const rules = [
  "RULE-SET,adrules_domain,REJECT",
  "RULE-SET,adrules_ip,REJECT",
  "RULE-SET,custom-proxy,PROXY",

  // 内网流量
  "RULE-SET,private_domain,DIRECT",
  "RULE-SET,private_ip,DIRECT,no-resolve",

  // 国内流量
  "RULE-SET,games_cn_domain,DIRECT",
  "RULE-SET,microsoft_cn_domain,Microsoft",
  "RULE-SET,socialmedia_cn_domain,DIRECT",
  "RULE-SET,socialmedia_cn_ip,DIRECT,no-resolve",
  "RULE-SET,httpdns_domain,DIRECT",
  "RULE-SET,httpdns_ip,DIRECT,no-resolve",
  "RULE-SET,cn_domain,DIRECT",
  "RULE-SET,cn_ip,DIRECT,no-resolve",

  // 国外流量
  "RULE-SET,Ai_Domain,AI",
  "RULE-SET,gits_domain,PROXY",
  "RULE-SET,cdn_domain,PROXY",
  "RULE-SET,tiktok_domain,TikTok",
  "RULE-SET,tld_proxy_domain,PROXY",
  "RULE-SET,proxy_domain,PROXY",
  "RULE-SET,proxy_ip,PROXY,no-resolve",

  "MATCH,default",
];

const sniffConfig = {
  enable: true,
  "force-dns-mapping": true,
  "parse-pure-ip": true,
  "override-destination": false,
  sniff: {
    HTTP: {
      ports: [80, 443],
    },
    TLS: {
      ports: [443],
    },
  },
  "skip-domain": ["Mijia Cloud", "dlg.io.mi.com", "+.push.apple.com"],
};

const bypassPrivateAddressSet = [
  "198.51.100.0/30",
  "1.0.0.0/8",
  "2.0.0.0/7",
  "4.0.0.0/6",
  "8.0.0.0/7",
  "11.0.0.0/8",
  "12.0.0.0/6",
  "16.0.0.0/4",
  "32.0.0.0/3",
  "64.0.0.0/3",
  "96.0.0.0/4",
  "112.0.0.0/5",
  "120.0.0.0/6",
  "124.0.0.0/7",
  "126.0.0.0/8",
  "128.0.0.0/3",
  "160.0.0.0/5",
  "168.0.0.0/8",
  "169.0.0.0/9",
  "169.128.0.0/10",
  "169.192.0.0/11",
  "169.224.0.0/12",
  "169.240.0.0/13",
  "169.248.0.0/14",
  "169.252.0.0/15",
  "169.255.0.0/16",
  "170.0.0.0/7",
  "172.0.0.0/12",
  "172.32.0.0/11",
  "172.64.0.0/10",
  "172.128.0.0/9",
  "173.0.0.0/8",
  "174.0.0.0/7",
  "176.0.0.0/4",
  "192.0.0.0/9",
  "192.128.0.0/11",
  "192.160.0.0/13",
  "192.169.0.0/16",
  "192.170.0.0/15",
  "192.172.0.0/14",
  "192.176.0.0/12",
  "192.192.0.0/10",
  "193.0.0.0/8",
  "194.0.0.0/7",
  "196.0.0.0/6",
  "200.0.0.0/5",
  "208.0.0.0/4",
  "2000::/3",
];
const tunConfig = {
  enable: true,
  stack: "mixed",
  "auto-route": true,
  "auto-detect-interfacce": true,
  "auto-redirect": true,
  // "route-exclude-address-set": ["GEOIP:private"],
  // "route-exclude-address": bypassPrivateAddressSet,
};

const direct_nameserver = [
  "https://119.29.29.29/dns-query",
  "https://223.5.5.5/dns-query",
];

const proxy_nameserver = [
  "https://cloudflare-dns.com/dns-query",
  "https://dns.google/dns-query",
];

const dnsConfig = {
  enable: true,
  "prefer-h3": true,
  "use-hosts": true,
  "enhanced-mode": "fake-ip",
  "fake-ip-filter": [
    "+.local",
    "time.*.com",
    "ntp.*.com",
    "dns.google",
    "cloudflare-dns.com",
    "rule-set:fake_ip_filter_domain",
    "+.miwifi.com",
  ],
  "fake-ip-range": "198.18.0.1/16",
  // 用于解析dns域名
  "default-nameserver": ["223.5.5.5", "119.29.29.29"],
  // 直连走这里
  "direct-nameserver": direct_nameserver,
  // 会优先走这个配置项
  "nameserver-policy": {
    "rule-set:adrules_domain": ["rcode://name_error"],
    "rule-set:cn_domain,socialmedia_cn_domain,games_cn_domain": [
      // "system",
      ...direct_nameserver,
    ],
    "rule-set:proxy_domain,tld_proxy_domain,gits_domain": [
      "https://cloudflare-dns.com/dns-query",
      "https://dns.google/dns-query",
    ],
  },
  // 其次nameserver 与 fallback 一起查询，使用fallback-filter确认该采用哪个
  nameserver: proxy_nameserver,
  // 国外doh 必须使用域名请求
  fallback: [],
};

const geoxURL = {
  geosite:
    "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat",
  geoip:
    "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat",
  mmdb: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.metadb",
  asn: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/GeoLite2-ASN.mmdb",
};

const countryMeta = {
  港澳台新: {
    pattern:
      "(?i)香港|港|澳门|台|新北|彰化|新加坡|坡|SG|TW|Taiwan|MO|Macau|HK|hk|Hong Kong|HongKong|hongkong|🇭",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Hong_Kong.png",
  },
  日韩: {
    pattern:
      "(?i)首尔|韩|KR|Korea|日本|川日|东京|大阪|泉日|埼玉|沪日|深日|JP|Japan|🇯",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Japan.png",
  },
  美国: {
    pattern: "(?i)美国|美|US|United States|🇺",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/United_States.png",
  },
  东南亚: {
    pattern: "(?i)泰国|马来西亚|马来|越南|菲律宾|印度尼西亚|孟加拉",
    icon: "",
  },
  澳大利亚: {
    pattern: "(?i)澳洲|澳大利亚|AU|Australia|🇦",
    icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Australia.png",
  },
};

function parseCountry(config) {
  const proxies = config.proxies || [];
  // 统计各个国家节点数
  const countryCounts = Object.create(null);
  // 构建地区正则表达式，去除(?i)
  const compileRegex = {};
  for (const [country, meta] of Object.entries(countryMeta)) {
    compileRegex[country] = new RegExp(
      meta.pattern.replace(/^\(\?i\)/, ""),
      "i",
    );
  }

  for (const proxy of proxies) {
    const name = proxy.name || "";
    // 找到第一个匹配的地区计数就终止
    for (const [country, re] of Object.entries(compileRegex)) {
      if (re.test(name)) {
        countryCounts[country] = (countryCounts[country] || 0) + 1;
        break;
      }
    }
  }

  // 将结果转换为数组对象
  const result = [];
  for (const [country, count] of Object.entries(countryCounts)) {
    result.push({ country, count });
  }
  return result;
}

function buildCountryProxyGroups(countryInfo) {
  const countryProxyGroups = [];

  // 为实际存在的地区创建节点组
  for (const info of countryInfo) {
    const country = info.country;
    const groupName = `${country}节点`;
    const pattern = countryMeta[country].pattern;
    const groupConfig = {
      name: groupName,
      icon: countryMeta[country].icon,
      "include-all": true,
      filter: pattern,
      type: loadBalance ? "load-balance" : "url-test",
    };

    if (!loadBalance) {
      Object.assign(groupConfig, {
        url: "https://cp.cloudflare.com/generate_204",
        interval: 60,
        tolerance: 20,
        lazy: false,
      });
    }
    countryProxyGroups.push(groupConfig);
  }
  return countryProxyGroups;
}

function buildProxyGroups(countryProxyGroups) {
  return [
    {
      name: "default",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Direct.png",
      type: "select",
      proxies: ["DIRECT", "PROXY", "ALL"],
    },
    {
      name: "PROXY",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Proxy.png",
      type: "select",
      proxies: ["DIRECT", "港澳台新节点", "日韩节点", "东南亚节点", "ALL"],
    },
    {
      name: "AI",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Bot.png",
      type: "select",
      proxies: ["港澳台新节点", "日韩节点", "东南亚节点", "ALL"],
    },
    {
      name: "TG",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Global.png",
      type: "select",
      proxies: ["PROXY", "港澳台新节点", "日韩节点", "东南亚节点", "ALL"],
    },
    {
      name: "TikTok",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/TikTok.png",
      type: "select",
      "include-all-proxies": true,
    },
    {
      name: "Microsoft",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Microsoft.png",
      type: "select",
      proxies: ["DIRECT", "PROXY"],
    },
    {
      name: "ALL",
      icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Global.png",
      type: "select",
      "include-all": true,
    },
    ...countryProxyGroups,
  ].filter(Boolean);
}

function parseBool(value) {
  if (typeof value === "boolean") return value;
  if (typeof value === "string") {
    return value.toLowerCase() === "true" || value === "1";
  }
  return false;
}

function main(config) {
  config = { proxies: config.proxies };
  const countryInfo = parseCountry(config);
  const countryProxyGroups = buildCountryProxyGroups(countryInfo);
  const proxyGroups = buildProxyGroups(countryProxyGroups);

  if (full) {
    Object.assign(config, {
      "mixed-port": 7890,
      "redir-port": 7892,
      "tproxy-port": 7893,
      "routing-mark": 6666,
      "allow-lan": true,
      mode: "rule",
      "unified-delay": true,
      "tcp-concurrent": true,
      tun: tunConfig,
      profile: {
        "store-selected": true,
        "store-fake-ip": true,
      },
    });
  }

  Object.assign(config, {
    "proxy-groups": proxyGroups,
    "rule-providers": ruleProviders,
    rules: rules,
    sniffer: sniffConfig,
    dns: dnsConfig,
    tun: tunConfig,
    profile: {
      "store-selected": true,
      "store-fake-ip": true,
    },
    "geodata-mode": true,
    "geo-auto-update": true,
    "geo-update-interval": 24,
    "geox-url": geoxURL,
  });

  return config;
}
