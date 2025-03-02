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
