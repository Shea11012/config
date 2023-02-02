let proxies = {
  name: "PROXY",
  type: "select",
  proxies: [],
};

module.exports.parse = async function (
  raw,
  { axios, yaml, notify, console },
  { name, url, interval, selected }
) {
  let content = yaml.parse(raw);

  // 清空proxy-groups
    delete content["proxy-groups"];
    delete content["rules"];

  // 自定义proxy groups
  for (let proxy of content.proxies) {
    proxies.proxies.push(proxy.name);
  }

  content["proxy-groups"] = proxies;

  let res = yaml.stringify(content);

  console.log(res);
  return res;
};
