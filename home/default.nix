{
  config,
  pkgs,
  lib,
  username,
  mysecrets,
  ...
}:
let
  zsxh-emacs = pkgs.emacs-igc.override {
    withNativeCompilation = false;
  };
in
{
  imports = [
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.05";
  };

  home.packages =
    with pkgs;
    [
      # editor
      # TODO: upgrade packages exclude external packages managed by nix
      ((emacsPackagesFor zsxh-emacs).emacsWithPackages (
        epkgs: with epkgs; [
          vterm
          pdf-tools
          # link tree-sitter grammar libs to user-emacs-directory
          # check: https://discourse.nixos.org/t/packages-required-to-get-emacs-typescript-ts-mode-to-work/31225/13
          treesit-grammars.with-all-grammars
        ]
      ))
      emacsPackages.telega
      emacs-lsp-booster

      # program languages
      clojure
      go
      nodejs
      python3
      typescript

      # lsp servers
      nixd
      nixfmt-rfc-style # nix formatter
      lua-language-server
      # basedpyright
      pyright
      ruff # python linter
      black # python formatter
      typescript-language-server
      vscode-langservers-extracted # HTML/CSS/JSON/ESLint language servers
      yaml-language-server
      jdt-language-server
      clojure-lsp
      gopls

      # devtools
      jq
      act
      buildpack
      kubernetes-helm
      k3d
      k9s
      kubectl
      lazydocker
      maven
      pnpm
      pdm
      mkcert
      termshark
      iredis
      aider-chat
      ffmpegthumbnailer # Lightweight video thumbnailer
      epub-thumbnailer
      vips
      mediainfo # Supplies technical and tag information about a video or audio file
      imagemagick # Software suite to create, edit, compose, or convert bitmap images
      poppler_utils # PDF rendering library
      _7zz # Programs provided: 7zz, Command line archiver utility
      fd
      bat # Cat(1) clone with syntax highlighting and Git integration
      xclip # Tool to access the X clipboard from a console application
      ripgrep
      gh # GitHub CLI tool
      htop
      fastfetch
      git-extras # GIT utilities -- repo summary, repl, changelog population, author commit percentages and more
      age # Modern encryption tool with small explicit keys
      yazi # terminal file manager written in Rust
      lazygit # A simple terminal UI for git commands
      lazysql # A cross-platform TUI database management tool written in Go.
      ffmpeg
      eza # A modern replacement for ‘ls’.
      # nix-index # Programs provided: nix-channel-index, nix-index, nix-locate
      python313Packages.huggingface-hub # Programs provided: huggingface-cli
      hurl # Command line tool that performs HTTP requests defined in a simple plain text format
      whisper-cpp # High-performance inference of OpenAI's Whisper automatic speech recognition (ASR) model
      unrar
      hugo # Fast and modern static website engine
      # zsh-history-to-fish

      # gui apps
      # firefox-devedition-unwrapped
      google-chrome
      telegram-desktop
      mpv-unwrapped
      jetbrains.idea-community
      # kanata # TODO: cross-platform software keyboard remapper for Linux, macOS and Windows
    ]
    ++ lib.optionals stdenv.isDarwin [
      # NOTE: Add "nix" to the "allow full disk access" security list if the build fails
      # with 'Operation not permitted' for some packages
      utm # virtual machine
    ]
    ++ lib.optionals stdenv.isLinux [
      wireshark
      docker
    ];

  home.file = {
    ".authinfo.age".source = "${mysecrets}/.authinfo.age";
    # tree-sitter subdirectory of the directory specified by user-emacs-directory
    # ".emacs.d/tree-sitter".source = "${(pkgs.emacsPackagesFor zsxh-emacs).treesit-grammars.with-all-grammars}/lib";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';

  home.sessionVariables = {
    # mirrors
    HF_ENDPOINT = "https://hf-mirror.com"; # huggingface 国内镜像

    # Java runtimes
    JAVA_8_HOME = "${pkgs.jdk8}";
    JAVA_11_HOME = "${pkgs.jdk11}";
    JAVA_17_HOME = "${pkgs.jdk17}";
    JAVA_21_HOME = "${pkgs.jdk21}";
    JAVA_23_HOME = "${pkgs.jdk23}";
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;

      userName = username;
      userEmail = "bnbvbchen@gmail.com";

      extraConfig = {
        core = {
          quotepath = false;
        };
        merge = {
          conflictstyle = "zdiff3";
        };
        diff = {
          colorMoved = "default";
        };
        http = {
          "https://github.com" = {
            proxy = "socks5h://127.0.0.1:1080";
          };
          "https://codeberg.org" = {
            proxy = "socks5h://127.0.0.1:1080";
          };
          "https://gitlab.com" = {
            proxy = "socks5h://127.0.0.1:1080";
          };
          "https://192.168.11.194" = {
            sslVerify = false;
          };
        };
      };
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        if test -d (brew --prefix)"/share/fish/completions"
            set -p fish_complete_path (brew --prefix)/share/fish/completions
        end

        if test -d (brew --prefix)"/share/fish/vendor_completions.d"
            set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
        end

        if type -q orbctl
            orbctl completion fish | source
        end

        # 按键绑定
        bind ctrl-j down-or-search
        bind ctrl-k up-or-search
      '';
      loginShellInit = '''';
      shellInit = ''
        fish_add_path -ga ~/.orbstack/bin
      '';
      shellAliases = {
        ls = "ls --color=auto --group-directories-first";
        ll = "ls -l";
        la = "ls -a";
        mg = "mvn archetype:generate";
        shttp = "export http_proxy=http://127.0.0.1:1080/; export https_proxy=http://127.0.0.1:1080/;";
        uhttp = "unset http_proxy; unset https_proxy;";
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      zprof.enable = false;

      plugins = [
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
      ];

      sessionVariables = { };

      shellAliases = {
        ls = "ls --color=auto --group-directories-first";
        ll = "ls -l";
        la = "ls -a";
        mg = "mvn archetype:generate";
        shttp = "export http_proxy=http://127.0.0.1:1080/; export https_proxy=http://127.0.0.1:1080/;";
        uhttp = "unset http_proxy; unset https_proxy;";
      };

      # add to ~/.zshenv
      envExtra = ''
        skip_global_compinit=1
      '';

      # add to ~/.zprofile
      profileExtra = '''';

      # add to ~/.zshrc
      initExtraBeforeCompInit = ''
        # homebrew zsh completions
        fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
        [ -f ~/.orbstack/shell/init.zsh ] && source ~/.orbstack/shell/init.zsh 2>/dev/null || :
      '';
      completionInit = ''
        # 加快zsh启动速度
        autoload -Uz compinit
        if [[ -n $(print ~/.zcompdump(N.mh+24)) ]]; then
          # echo "缓存文件已过期"
          compinit
        else
          # echo "缓存文件未过期"
          compinit -C
        fi
        # 设置路径补全无视大小写
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      '';
      initExtra = '''';
    };

    # Cross-Shell Prompt
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        directory = {
          truncation_length = 3;
          fish_style_pwd_dir_length = 2;
        };
      };
    };

    # NOTE: bug: Shell integration is installed even with programs.fzf.enableFishIntegration = false
    # https://github.com/nix-community/home-manager/issues/5904
    fzf = {
      enable = false;
      enableFishIntegration = false;
      defaultCommand = "fd --type f"; # 使用 fd 作为默认搜索工具
      defaultOptions = [
        "--height 40%"
        "--reverse"
        "--border"
      ];
      changeDirWidgetOptions = [
        "--preview 'tree -C {} | head -200'"
      ];
      fileWidgetOptions = [
        "--preview 'bat --color=always {}' --preview-window '~3'"
      ];
    };

    # Fast cd command that learns your habits
    zoxide = {
      enable = true;
    };

    # terminal
    kitty = {
      enable = true;
      themeFile = "Doom_One";
      shellIntegration.mode = "no-cursor";
      settings = {
        font_family = "Fira Code";
        font_size = 16;
        cursor_shape = "block"; # 光标形状：beam、block 或 underline
        cursor_blink_interval = 0; # 禁止光标闪烁
        macos_option_as_alt = "both"; # Don't break any Alt+Key keyboard shortcuts
      };
    };

    # ghostty = {
    #   enable = true;
    #   settings = {
    #     theme = "DoomOne";
    #     font-family = "Fira Code";
    #     font-size = 16;
    #   };
    # };

    tmux = {
      enable = true;
      baseIndex = 1; # 窗口编号从1开始
      clock24 = true;
      escapeTime = 50; # ms
      prefix = "M-`";
      terminal = "screen-256color";
      mouse = true; # 启用鼠标支持
      keyMode = "vi";
      extraConfig = ''
        # 设置状态栏
        # $(echo $USER) - shows the current username
        # #H - shows the hostname of your computer
        # %h %d %Y - date in the [Mon DD YYYY] format
        # %l:%M %p - time in the [HH:MM AM/PM] format
        set -g status-right "#H %l:%M %p %Y-%m-%d%a"

        # 绑定快捷键
        bind c new-window -c "#{pane_current_path}"
        bind / split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        unbind '"' # 取消默认的水平分割快捷键
        unbind %   # 取消默认的垂直分割快捷键

        # 用于在窗格（pane）之间快速切换
        bind h select-pane -L
        bind l select-pane -R
        bind k select-pane -U
        bind j select-pane -D
      '';
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # set JAVA_HOME
    java = {
      enable = true;
      package = pkgs.jdk23;
    };

    # firefox = {
    #   enable = true;
    #   package = pkgs.firefox-devedition-unwrapped;
    #   languagePacks = ["zh-CN"];
    # };
  };

  # mirror
  xdg.configFile."pip/pip.conf".text = ''
    [global]
    index-url = https://pypi.tuna.tsinghua.edu.cn/simple
    format = columns
  '';
  home.file.".npmrc".text = ''
    registry=https://registry.npmmirror.com
  '';
  # 国内的 Docker Hub 镜像加速器
  # https://gist.github.com/y0ngb1n/7e8f16af3242c7815e7ca2f0833d3ea6
  # https://github.com/DaoCloud/public-image-mirror
  home.file.".orbstack/config/docker.json".text = ''
    {
      "registry-mirrors": [
        "https://docker.m.daocloud.io"
      ]
    }
  '';

}
