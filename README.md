# Darwin

## Install Nix

Add configs to `/etc/nix/nix.conf` then restart nix services.

``` conf
# add configs
experimental-features = nix-command flakes
trusted-users = root <yourname>
substituters = "https://mirrors.sustech.edu.cn/nix-channels/store" "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" "https://mirrors.ustc.edu.cn/nix-channels/store" "https://cache.nixos.org" "https://nix-community.cachix.org"
```

## Install Nix-Darwin

- build config
- switch config

## Others

### clash-verge-rev rules

```js
/**
  * 配置中的规则"config.rules"是一个数组，通过新旧数组合并来添加
  * @param prependRule 添加的数组
  *
  * 全局拓展脚本
  * https://www.clashverge.dev/guide/rules.html
  */
const prependRule = [
  // 将hf-mirror.com分流到直连
  "DOMAIN-SUFFIX,hf-mirror.com,DIRECT",
  // 将本网站分流到自动选择(前提是你的代理组当中有"自动选择")
  // "DOMAIN-SUFFIX,clashverge.dev,自动选择",
];
function main(config) {
  // 把旧规则合并到新规则后面(也可以用其它合并数组的办法)
  let oldrules = config["rules"];
  config["rules"] = prependRule.concat(oldrules);
  return config;
}
```
