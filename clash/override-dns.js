// https://clashparty.org/docs/guide/override/javascript
const nameServerPolicy = {
    "+.u53e3.com,*.u53e3.com": [
        "https://119.29.29.29/dns-query",
        "https://223.5.5.5/dns-query",
    ],
};

const providerRules = [
    "IP-CIDR,103.213.5.37/32,DIRECT,no-resolve",
    "IP-CIDR,216.38.168.235/32,DIRECT,no-resolve",
    "IP-CIDR,216.23.109.34/32,DIRECT,no-resolve",
    "IP-CIDR,151.242.182.253/32,DIRECT,no-resolve",
    "DOMAIN,domain.u53e3.com,DIRECT",
    "DOMAIN,oneinlink.u53e3.com,DIRECT",
    "DOMAIN-SUFFIX,u53e3.com,DIRECT",
];

const fakeIpFilter = ["+.u53e3.com"];

const hosts = { "+.local": "192.168.0.107" };

function main(config) {
    config.hosts = { ...config.hosts, ...hosts };

    config.dns["nameserver-policy"] = {
        ...nameServerPolicy,
        ...config.dns["nameserver-policy"],
    };
    config.dns["fake-ip-filter"] = [
        ...fakeIpFilter,
        ...config.dns["fake-ip-filter"],
    ];

    config.rules = [...providerRules, ...config.rules];

    return config;
}
