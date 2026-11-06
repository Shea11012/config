const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const test = require("node:test");

const source = fs.readFileSync(path.join(__dirname, "convert.js"), "utf8");

function load(args) {
  const context = vm.createContext(args === undefined ? {} : { $arguments: args });
  vm.runInContext(source, context);
  return context;
}

function input(names) {
  return {
    proxies: names.map((name) => ({
      name,
      type: "ss",
      server: "127.0.0.1",
      port: 8388,
      cipher: "aes-128-gcm",
      password: "test-only",
    })),
  };
}

function regionNames(config) {
  return Array.from(config["proxy-groups"].filter((g) => g.filter), (g) => g.name);
}

function assertReferences(config) {
  const names = new Set([
    "DIRECT",
    "REJECT",
    ...config.proxies.map((p) => p.name),
    ...config["proxy-groups"].map((g) => g.name),
  ]);
  for (const group of config["proxy-groups"]) {
    for (const name of group.proxies || []) {
      assert.ok(names.has(name), `${group.name} references missing ${name}`);
    }
  }
}

test("all nonempty region combinations produce valid references in both modes", () => {
  const samples = ["香港 01", "新加坡 01", "日本 01", "美国 01", "泰国 01", "澳大利亚 01"];
  for (const loadbalance of [false, true]) {
    const context = load({ loadbalance });
    for (let mask = 1; mask < 1 << samples.length; mask++) {
      const names = samples.filter((_, index) => mask & (1 << index));
      const config = context.main(input(names));
      assertReferences(config);
      const present = new Set(regionNames(config));
      const preferred = [
        "港澳台节点", "新加坡节点", "日韩节点", "美国节点", "东南亚节点", "澳大利亚节点",
      ].filter((n) => present.has(n));
      const groups = Object.fromEntries(config["proxy-groups"].map((g) => [g.name, g]));
      assert.deepEqual(Array.from(groups.PROXY.proxies), [...preferred, "ALL", "DIRECT"]);
      for (const group of [groups.AI, groups.TikTok]) {
        assert.equal(group.type, "select");
        assert.equal(group["include-all-proxies"], true);
        assert.equal(group.proxies, undefined, "business groups contain no automatic or shared groups");
      }
      assert.equal(groups.TG, undefined);
      for (const group of config["proxy-groups"].filter((g) => g.filter)) {
        assert.equal(group.type, loadbalance ? "load-balance" : "url-test");
      }
    }
  }
});

test("routing rules reference existing providers and outbound groups", () => {
  const config = load().main(input(["香港 01", "新加坡 01", "美国 01"]));
  const outbounds = new Set(["DIRECT", "REJECT", ...config["proxy-groups"].map((g) => g.name)]);
  for (const rule of config.rules) {
    const parts = rule.split(",");
    if (parts[0] === "RULE-SET") {
      assert.ok(config["rule-providers"][parts[1]], `missing provider: ${rule}`);
    }
    const target = parts[0] === "MATCH" ? parts[1] : parts[2];
    assert.ok(outbounds.has(target), `missing outbound: ${rule}`);
  }
});

test("dedicated services take precedence over broad domestic and CDN routes", () => {
  const config = load().main(input(["新加坡 01"]));
  const position = (rule) => {
    const index = config.rules.indexOf(rule);
    assert.notEqual(index, -1, `missing rule: ${rule}`);
    return index;
  };
  const ai = position("RULE-SET,Ai_Domain,AI");
  const tiktok = position("RULE-SET,tiktok_domain,TikTok");
  assert.ok(ai < tiktok, "shared AI/TikTok domains retain the AI policy");
  for (const rule of [
    "RULE-SET,cn_domain,DIRECT",
    "RULE-SET,cn_ip,DIRECT,no-resolve",
    "RULE-SET,cdn_domain,PROXY",
    "RULE-SET,proxy_domain,PROXY",
  ]) {
    assert.ok(tiktok < position(rule), `service policy must precede ${rule}`);
  }
  assert.ok(position("RULE-SET,custom-direct,DIRECT,no-resolve") < ai);
  assert.ok(position("RULE-SET,custom-proxy,PROXY") < ai);
  assert.equal(config.rules.at(-1), "MATCH,default");
});

test("IP rules avoid forced resolution and HTTPDNS uses the existing ad block", () => {
  const config = load().main(input(["新加坡 01"]));
  assert.ok(config.rules.includes("RULE-SET,adrules_domain,REJECT"));
  assert.ok(config.rules.includes("RULE-SET,adrules_ip,REJECT,no-resolve"));
  assert.equal(config["rule-providers"].httpdns_domain, undefined);
  assert.equal(config["rule-providers"].httpdns_ip, undefined);
  for (const rule of config.rules) {
    const [type, provider, , option] = rule.split(",");
    assert.ok(!provider.startsWith("httpdns_"), `redundant HTTPDNS rule: ${rule}`);
    if (type === "RULE-SET" && config["rule-providers"][provider].behavior === "ipcidr") {
      assert.equal(option, "no-resolve", `unexpected forced lookup: ${rule}`);
    }
  }
});

test("country matching handles full flags, English names and compact codes", () => {
  const context = load();
  const cases = [
    ["Australia 01", "澳大利亚节点"],
    ["🇦🇺 01", "澳大利亚节点"],
    ["🇺🇸 01", "美国节点"],
    ["US01", "美国节点"],
    ["Uſ01", "美国节点"],
    ["USA 01", "美国节点"],
    ["United States 01", "美国节点"],
    ["美01", "美国节点"],
    ["🇭🇰 01", "港澳台节点"],
    ["🇲🇴 01", "港澳台节点"],
    ["🇹🇼 01", "港澳台节点"],
    ["🇸🇬 01", "新加坡节点"],
    ["SG01", "新加坡节点"],
    ["坡01", "新加坡节点"],
    ["hk01", "港澳台节点"],
    ["HongKong 01", "港澳台节点"],
    ["Macau 01", "港澳台节点"],
    ["Singapore 01", "新加坡节点"],
    ["港01", "港澳台节点"],
    ["🇯🇵 01", "日韩节点"],
    ["🇰🇷 01", "日韩节点"],
    ["JP01", "日韩节点"],
    ["深日 01", "日韩节点"],
    ["马来西亚 吉隆坡 01", "东南亚节点"],
    ["🇲🇾 01", "东南亚节点"],
    ["TH01", "东南亚节点"],
  ];
  for (const [name, expected] of cases) {
    assert.deepEqual(regionNames(context.main(input([name]))), [expected], name);
  }
});

test("unrecognized countries and embedded abbreviations remain available through ALL", () => {
  const context = load();
  for (const name of [
    "Russia 01", "🇦🇹 Vienna 01", "🇭🇺 Budapest 01", "🇯🇲 Kingston 01",
    "🇺🇦 Kyiv 01", "🇬🇧 UK 01", "AUS 01", "Remote 01", "南美 01", "未分类 01", "HKK",
    "孟加拉 01", "Bangladesh 01", "BD01", "🇧🇩 01",
  ]) {
    const config = context.main(input([name]));
    assert.deepEqual(regionNames(config), [], name);
    assertReferences(config);
    const groups = Object.fromEntries(config["proxy-groups"].map((g) => [g.name, g]));
    assert.deepEqual(Array.from(groups.PROXY.proxies), ["ALL", "DIRECT"]);
    assert.equal(groups.AI["include-all-proxies"], true);
    assert.equal(groups.TikTok["include-all-proxies"], true);
    assert.equal(groups.ALL["include-all"], true);
    assert.equal(config.proxies[0].name, name);
  }
});

test("adjacent flags match only complete pairs", () => {
  const context = load();
  const cases = [
    ["🇺🇸🇬🇧", ["美国节点"]],
    ["🇯🇵🇭🇰", ["港澳台节点", "日韩节点"]],
    ["🇦🇺🇸🇬", ["新加坡节点", "澳大利亚节点"]],
    ["🇸🇬🇺🇸", ["新加坡节点", "美国节点"]],
    ["🇭🇰🇸🇬", ["港澳台节点", "新加坡节点"]],
  ];
  for (const [name, expected] of cases) {
    assert.deepEqual(regionNames(context.main(input([name]))), expected, name);
  }
});

test("overlapping names match every applicable group in a stable order", () => {
  const context = load();
  const names = ["香港 日本 01", "澳大利亚 01", "美国 01", "新加坡 01"];
  const expected = ["港澳台节点", "新加坡节点", "日韩节点", "美国节点", "澳大利亚节点"];
  for (const order of [names, [...names].reverse()]) {
    const config = context.main(input(order));
    assert.deepEqual(regionNames(config), expected);
    for (const group of config["proxy-groups"].filter((g) => g.filter)) {
      const regex = new RegExp(group.filter.replace(/^\(\?i\)/, ""), "iu");
      assert.ok(order.some((name) => regex.test(name)), group.name);
    }
  }
});

test("missing, empty and malformed node inputs fail with actionable errors", () => {
  const context = load();
  for (const config of [undefined, null, {}, { proxies: [] }, { proxies: {} }]) {
    assert.throws(() => context.main(config), /需要非空的 proxies 数组/);
  }
  for (const proxy of [null, {}, { name: 123 }, { name: " " }]) {
    assert.throws(() => context.main({ proxies: [proxy] }), /缺少有效的 name/);
  }
});

test("complete config and TUN are always enabled, ignoring the removed full argument", () => {
  const config = input(["香港 01"]);
  const baseline = load().main(config);
  assert.equal(baseline.tun.enable, true);
  assert.equal(baseline["mixed-port"], 7890);
  assert.equal(baseline["redir-port"], 7892);
  assert.equal(baseline["tproxy-port"], 7893);
  assert.equal(baseline.mode, "rule");
  assert.equal(baseline.profile["store-selected"], true);
  assert.equal(baseline.profile["store-fake-ip"], true);
  for (const full of [false, true, "false", "true"]) {
    assert.deepEqual(
      JSON.parse(JSON.stringify(load({ full }).main(config))),
      JSON.parse(JSON.stringify(baseline)),
    );
  }
  assert.deepEqual(config, input(["香港 01"]));
});
