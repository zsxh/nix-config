{
  description = "zsxh's nix configuration for both NixOS & macOS";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      # "https://mirrors.sustech.edu.cn/nix-channels/store"
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      # the default public key of cache.nixos.org, it's built-in, no need to add it here
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay/10d6d819894ab08fa2c2d3d3d472a1fe92a7d113";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # moonbit-overlay = {
    #   url = "github:jetjinser/moonbit-overlay/d3100f61740a45bdb8e7c061f411338562599d7f";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # secrets management
    agenix = {
      url = "github:ryantm/agenix";
      # url = "github:ryan4yin/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # my private secrets, it's a private repository
    mysecrets = {
      url = "git+ssh://git@github.com/zsxh/nix-secrets.git?shallow=1";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nix-darwin,
      home-manager,
      emacs-overlay,
      # moonbit-overlay,
      ...
    }:
    let
      username = "zsxh";
      specialArgs = inputs // {
        inherit username;
      };
    in
    {
      # Build/Switch darwin flake using:
      # $ darwin-rebuild build --flake .#macbook
      # $ nix flake update
      # $ darwin-rebuild switch --flake .#macbook
      #
      # Use Nix Cli helper nh
      # $ nh darwin switch .#darwinConfigurations.macbook --update
      # $ nh darwin switch .#darwinConfigurations.macbook --update-input emacs-overlay
      # $ nh darwin switch .#darwinConfigurations.macbook
      # $ NH_FLAKE=.#darwinConfigurations.macbook" nh darwin switch
      darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [
          ./secrets/darwin.nix
          ./modules

          # home manager
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [
              # (import ./overlays/mps-overlay.nix)
              emacs-overlay.overlay
              # moonbit-overlay.overlays.default
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "home-manager.backup";
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.users.${username}.imports = [
              ./secrets/home.nix
              ./home
            ];
          }
        ];
      };
    };
}
