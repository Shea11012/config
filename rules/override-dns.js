// https://clashparty.org/docs/guide/override/javascript
const nameServerPolicy = {
    "+.u53e3.com,*.u53e3.com": [
        "https://119.29.29.29/dns-query",
        "https://223.5.5.5/dns-query",
    ],
};

const providerRules = [
    "DOMAIN,domain.u53e3.com,DIRECT",
    "DOMAIN,oneinlink.u53e3.com,DIRECT",
    "DOMAIN-SUFFIX,u53e3.com,DIRECT",
];

const fakeIpFilter = ["+.u53e3.com"];

function main(config) {
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
