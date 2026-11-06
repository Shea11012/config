/*
默认输出完整配置并启用 TUN。
- loadbalance: 启用负载均衡（默认 false）
 */

const inArg = typeof $arguments !== "undefined" ? $arguments : {};
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
			"http://arch.local/assets/clash/custom_proxy.yaml",
		),
		format: "yaml",
	},
	"custom-direct": {
		...domainRuleProvider(
			"http://arch.local/assets/clash/custom-direct.yaml",
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
	"DOMAIN-SUFFIX,2722222.xyz,DIRECT,no-resolve",
	"DOMAIN-SUFFIX,u53e3.com,DIRECT,no-resolve",
	"RULE-SET,custom-direct,DIRECT,no-resolve",
	// 上游广告集已包含 HTTPDNS；IP 规则只检查已有地址，避免提前解析域名。
	"RULE-SET,adrules_domain,REJECT",
	"RULE-SET,adrules_ip,REJECT,no-resolve",
	"RULE-SET,custom-proxy,PROXY",

	// 内网流量
	"RULE-SET,private_domain,DIRECT",
	"RULE-SET,private_ip,DIRECT,no-resolve",

	// 专用业务先于通用国内 / CDN 规则；AI 优先处理与 TikTok 集重叠的域名。
	"RULE-SET,Ai_Domain,AI",
	"RULE-SET,tiktok_domain,TikTok",

	// 国内流量
	"RULE-SET,games_cn_domain,DIRECT",
	"RULE-SET,microsoft_cn_domain,Microsoft",
	"RULE-SET,socialmedia_cn_domain,DIRECT",
	"RULE-SET,socialmedia_cn_ip,DIRECT,no-resolve",
	"RULE-SET,cn_domain,DIRECT",
	"RULE-SET,cn_ip,DIRECT,no-resolve",

	// 国外流量
	"RULE-SET,gits_domain,PROXY",
	"RULE-SET,cdn_domain,PROXY",
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

const tunConfig = {
	enable: true,
	stack: "mixed",
	"auto-route": true,
	"auto-detect-interface": true,
	"auto-redirect": true,
	// "route-exclude-address-set": ["private_ip"],
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
		"*.lan",
		"*.localdomain",
		"*.home.arpa",
		"localhost",
		"*.u53e3.com",
		"*.2722222.xyz",
		"+.local",
		"doh.pub",
		"dns.alidns.com",
		"dns.google",
		"cloudflare-dns.com",
		"*.pool.ntp.org",
		"connectivitycheck.gstatic.com",
		"connectivitycheck.android.com",
		"www.msftconnecttest.com",
		"www.msftncsi.com",
		"captive.apple.com",
		"detectportal.firefox.com",
		"stun.l.google.com",
		"stun1.l.google.com",
		"stun2.l.google.com",
		"stun3.l.google.com",
		"stun4.l.google.com",
		"time.*.com",
		"ntp.*.com",
		"ntp.*.cn",
		"rule-set:fake_ip_filter_domain",
		"+.miwifi.com",
	],
	"fake-ip-range": "198.18.0.1/16",
	// 用于解析 DNS 服务器自身的域名
	"default-nameserver": ["223.5.5.5", "119.29.29.29"],
	// 用于 DIRECT 出站连接的目标域名解析
	"direct-nameserver": direct_nameserver,
	// 按查询域名选择上游，优先于普通 nameserver 查询
	"nameserver-policy": {
		"+.u53e3.com": direct_nameserver,
		"rule-set:adrules_domain": ["rcode://name_error"],
		"rule-set:cn_domain,socialmedia_cn_domain,games_cn_domain": [
			// "system",
			...direct_nameserver,
		],
	},
	// 未命中 nameserver-policy 的普通查询使用这些上游
	nameserver: proxy_nameserver,
};

const geoxURL = {
	geosite: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat",
	geoip: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat",
	mmdb: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.metadb",
	asn: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/GeoLite2-ASN.mmdb",
};

// 使用 JS / Go 正则均支持的边界写法，允许 HK01 等带数字的缩写。
function countryPattern(keywords, englishNames, flags, shortNames = []) {
	const parts = [
		...keywords,
		`(^|[^a-z])(${englishNames.join("|")})([^a-z]|$)`,
		// 连续国旗必须从成对边界匹配，避免将 🇺🇸🇬🇧 中间的 🇸🇬 识别为新加坡。
		`(^|[^🇦-🇿])([🇦-🇿]{2})*(${flags.join("|")})`,
	];
	if (shortNames.length > 0) {
		parts.push(
			`(^|[^a-z一-鿿])(${shortNames.join("|")})([^a-z一-鿿]|$)`,
		);
	}
	return `(?i)${parts.join("|")}`;
}

const countryMeta = {
	港澳台: {
		pattern: countryPattern(
			[
				"香港",
				"澳门",
				"澳門",
				"台湾",
				"台灣",
				"新北",
				"彰化",
			],
			[
				"HK",
				"MO",
				"TW",
				"Hong Kong",
				"HongKong",
				"Macau",
				"Macao",
				"Taiwan",
			],
			["🇭🇰", "🇲🇴", "🇹🇼"],
			["港", "台"],
		),
		icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Hong_Kong.png",
	},
	新加坡: {
		pattern: countryPattern(
			["新加坡"],
			["SG", "Singapore"],
			["🇸🇬"],
			["坡"],
		),
		icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Singapore.png",
	},
	日韩: {
		pattern: countryPattern(
			[
				"首尔",
				"首爾",
				"韩国",
				"韓國",
				"日本",
				"川日",
				"东京",
				"東京",
				"大阪",
				"泉日",
				"埼玉",
				"沪日",
				"深日",
			],
			["KR", "Korea", "JP", "Japan"],
			["🇯🇵", "🇰🇷"],
			["韩", "韓", "日"],
		),
		icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Japan.png",
	},
	美国: {
		pattern: countryPattern(
			["美国", "美國"],
			["US", "USA", "United States"],
			["🇺🇸"],
			["美"],
		),
		icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/United_States.png",
	},
	东南亚: {
		pattern: countryPattern(
			[
				"泰国",
				"泰國",
				"马来西亚",
				"馬來西亞",
				"马来",
				"越南",
				"菲律宾",
				"菲律賓",
				"印度尼西亚",
				"印尼",
			],
			[
				"TH",
				"MY",
				"VN",
				"PH",
				"ID",
				"Thailand",
				"Malaysia",
				"Vietnam",
				"Philippines",
				"Indonesia",
			],
			["🇹🇭", "🇲🇾", "🇻🇳", "🇵🇭", "🇮🇩"],
		),
		icon: "",
	},
	澳大利亚: {
		pattern: countryPattern(
			["澳洲", "澳大利亚", "澳大利亞"],
			["AU", "Australia"],
			["🇦🇺"],
		),
		icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Australia.png",
	},
};

const countryMatchers = Object.entries(countryMeta).map(([country, meta]) => ({
	country,
	regex: new RegExp(meta.pattern.replace(/^\(\?i\)/, ""), "iu"),
}));

function parseCountry(config) {
	// 与输出分组的 filter 一致：每个地区独立匹配，按固定地区顺序输出。
	return countryMatchers
		.map(({ country, regex }) => ({
			country,
			count: config.proxies.reduce(
				(count, proxy) =>
					count +
					(regex.test(proxy.name) ? 1 : 0),
				0,
			),
		}))
		.filter(({ count }) => count > 0);
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

// 业务候选顺序独立于地区识别，只保留当前订阅实际存在的分组。
const proxyRegionPreference = [
	"港澳台节点",
	"新加坡节点",
	"日韩节点",
	"美国节点",
	"东南亚节点",
	"澳大利亚节点",
];

function buildProxyGroups(countryProxyGroups) {
	const availableCountries = new Set(
		countryProxyGroups.map((group) => group.name),
	);
	const preferredCountries = proxyRegionPreference.filter((name) =>
		availableCountries.has(name),
	);
	// AI / TikTok 各自选择固定节点；地区自动组统一放在 PROXY 中。

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
			proxies: [...preferredCountries, "ALL", "DIRECT"],
		},
		{
			name: "AI",
			icon: "https://cdn.jsdelivr.net/gh/Koolson/Qure@master/IconSet/Color/Bot.png",
			type: "select",
			"include-all-proxies": true,
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
	];
}

function parseBool(value) {
	if (typeof value === "boolean") return value;
	if (typeof value === "string") {
		return value.toLowerCase() === "true" || value === "1";
	}
	return false;
}

function main(config) {
	if (
		!config ||
		!Array.isArray(config.proxies) ||
		config.proxies.length === 0
	) {
		throw new Error("订阅中没有可用节点：需要非空的 proxies 数组");
	}
	for (const proxy of config.proxies) {
		if (
			!proxy ||
			typeof proxy.name !== "string" ||
			proxy.name.trim() === ""
		) {
			throw new Error("订阅节点缺少有效的 name");
		}
	}

	config = { proxies: config.proxies };
	const countryInfo = parseCountry(config);
	const countryProxyGroups = buildCountryProxyGroups(countryInfo);
	const proxyGroups = buildProxyGroups(countryProxyGroups);

	Object.assign(config, {
		"mixed-port": 7890,
		"redir-port": 7892,
		"tproxy-port": 7893,
		"routing-mark": 6666,
		"allow-lan": true,
		mode: "rule",
		"unified-delay": true,
		"tcp-concurrent": true,
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
