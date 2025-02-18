{
  pkgs,
  lib,
  username,
  ...
}: {
  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];

    trusted-users = [username];

    # 指定二进制缓存服务器的 URL。Nix 会从这些服务器下载预构建的包，而不是从源码构建
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.sustech.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    # 指定信任的公钥列表。这些公钥用于验证从缓存服务器下载的包的签名。这里配置了两个公钥
    # trusted-public-keys = [
    #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # ];

    # 构建器（builders）可以使用缓存中的预构建包，而不是从头构建
    builders-use-substitutes = true;

    # Disable auto-optimise-store because of this issue:
    #   https://github.com/NixOS/nix/issues/7273
    # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
    auto-optimise-store = false;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.enable = true;
  nix.package = pkgs.nix;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };
}
