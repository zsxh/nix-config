{
  description = "zsxh's nix configuration for both NixOS & macOS";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    substituters = [
      "https://mirrors.sustech.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    # trusted-public-keys = [
    #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay/ad16925507732f4f57f6cc5595bdfa90d2692278";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    emacs-overlay,
    ...
  }: let
    username = "zsxh";
    specialArgs = inputs // {inherit username;};
  in {
    # Build/Switch darwin flake using:
    # $ darwin-rebuild build --flake .#macbook
    # $ nix flake update
    # $ darwin-rebuild switch --flake .#macbook
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [
        ./modules

        # home manager
        home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [emacs-overlay.overlay];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username}.imports = [./home];
        }
      ];
    };
  };
}
