{
  description = "zsxh's nix configuration for both NixOS & macOS";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    substituters = [
      # Query the mirror of USTC first, and then the official cache.
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    ...
  }: let
    username = "zsxh";
    specialArgs = inputs // {inherit username;};
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#macbook
    # Update
    # $ nix flake update
    # $ darwin-rebuild switch --flake .#macbook
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [
        ./modules

        # home manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username}.imports = [./home];
        }
      ];
    };
  };
}
