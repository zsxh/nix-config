{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Homebrew Mirror
  # NOTE: is only useful when you run `brew install` manually! (not via nix-darwin)
  homebrew_mirror_env = {
    # tuna mirror
    HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
    HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
    HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
    HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
    HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
  };
  homebrew_env_script = lib.attrsets.foldlAttrs (
    acc: name: value:
    acc + "\nexport ${name}=${value}"
  ) "" homebrew_mirror_env;
in
{
  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    vim
    git
    coreutils-full # 包含 GNU Coreutils 的工具集，如 `ls`, `cp`, `mv`, `rm` 等常用命令
    gnutar
    unzip
    tree
    wget
  ];

  environment.variables =
    {
      EDITOR = "vim";
      TIME_STYLE = "long-iso"; # ls -l 用长时间代替短时间格式
      EMACS_APP = "/Applications/Emacs.app/Contents/MacOS";
      PATH = "$PATH:/opt/homebrew/bin:$EMACS_APP:$EMACS_APP/bin";
    }
    # Set variables for you to manually install homebrew packages.
    // homebrew_mirror_env;

  # Set environment variables for nix-darwin before run `brew bundle`.
  system.activationScripts.homebrew.text = lib.mkBefore ''
    echo >&2 '${homebrew_env_script}'
    ${homebrew_env_script}
  '';

  # /etc/shells
  environment.shells = [
    pkgs.zsh
    pkgs.fish
  ];

  # NOTE: To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      cleanup = "zap";
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      WPS = 1443749478;
      Wechat = 836500024;
      WeCom = 1189898970; # Wechat for Work
      TecentMetting = 1484048379;
      BaiduNetDisk = 547166701;
      Xcode = 497799835;
      # NeteaseCloudMusic = 944848654;
      # QQ = 451108668;
      # QQMusic = 595615424;
    };

    taps = [
      # "homebrew/services"
      # "d12frosted/emacs-plus"
    ];

    # `brew install`
    brews = [
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!
      "gh"
      "mas"
      # "docker-completion"
      # {
      #   name = "emacs-plus@31";
      #   args = [];
      #   link = true;
      # }
      # "poppler"
      # "libvterm"
      # "tree-sitter"
    ];

    # `brew install --cask`
    casks = [
      # dev tools
      "lm-studio"
      "raycast"
      "orbstack"
      "wireshark"
      "visual-studio-code"
      "cherry-studio"
      "trae"
      "cursor"
      "redis-insight"

      # others
      "karabiner-elements"
      "scroll-reverser"
      "firefox@developer-edition"
      "clash-verge-rev"
      # "alt-tab"
    ];
  };
}
