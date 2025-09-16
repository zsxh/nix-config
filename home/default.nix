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
      # emacs
      ((emacsPackagesFor zsxh-emacs).emacsWithPackages (
        epkgs: with epkgs; [
          vterm
          # pdf-tools
          # (melpaPackages.telega) # 强制使用 melpa 版 telega，而不是 melpa-stable 版的
          treesit-grammars.with-all-grammars
        ]
      ))
      # emacsPackages.telega
      # emacs-lsp-booster
      (emacsPackagesFor zsxh-emacs).melpaPackages.telega
      (emacs-lsp-booster.override { emacs = zsxh-emacs; })

      # program languages
      clojure
      go
      nodejs_24
      # typescript
      bun
      python3
      uv

      # lsp servers
      nixd
      nixfmt-rfc-style # nix formatter
      lua-language-server
      basedpyright
      pyright # TODO: remove
      ruff # python linter
      black # python formatter
      typescript-language-server
      vscode-langservers-extracted # HTML/CSS/JSON/ESLint language servers
      yaml-language-server
      jdt-language-server
      clojure-lsp
      gopls
      go-tools # Collection of tools and libraries for working with Go code, including linters and static analysis
      gofumpt # Stricter gofmt
      delve
      gomodifytags
      gotests
      (pkgs.callPackage ./pkgs/go/reftools.nix { }) # fillstruct
      (pkgs.callPackage ./pkgs/go/impl.nix { }) # impl
      # moonbit-bin.lsp.latest

      # devtools
      jq
      yq-go
      act
      buildpack
      kubernetes-helm
      minikube
      # k3d
      k9s
      kubectl
      lazydocker
      maven
      pnpm
      mkcert
      termshark
      # iredis
      # aider-chat
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
      btop
      fastfetch
      git-extras # GIT utilities -- repo summary, repl, changelog population, author commit percentages and more
      git-lfs # Git extension for versioning large files
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
      grpcurl
      # harlequin # The SQL IDE for Your Terminal.
      mermaid-cli # FIXME: broken mmdc
      tokei # count code
      yt-dlp

      # ai tools
      claude-code

      # gui apps
      # firefox-devedition-unwrapped
      # google-chrome
      brave
      jetbrains.idea-community
      # kanata # TODO: cross-platform software keyboard remapper for Linux, macOS and Windows
      dbeaver-bin
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # NOTE: Add "nix" to the "allow full disk access" security list if the build fails
      # with 'Operation not permitted' for some packages
      utm # virtual machine
      vfkit # Simple command line tool to start VMs through the macOS Virtualization framework
      # lima
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      wireshark
      docker
      redisinsight
      telegram-desktop
      # game
      # ryubing # Nintendo Switch Emulator
    ]
    ++ [
      # self-hosted
      searxng # A privacy-respecting, hackable metasearch engine
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

    # Go
    GOPROXY = "https://goproxy.cn,direct";
    GOPATH = "${config.home.homeDirectory}/.local/share/go";
    GOROOT = "${pkgs.go}/share/go";
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
      '';
      loginShellInit = '''';
      shellInit = ''
        set -g fish_greeting
        fish_add_path -ga ~/.orbstack/bin
        fish_add_path -ga ~/.local/bin
        fish_add_path -ga "$HOME/.moon/bin"
      '';
      shellAliases = {
        ls = "ls --color=auto --group-directories-first";
        ll = "ls -lh";
        la = "ls -a";
        mg = "mvn archetype:generate";
        shttp = "export http_proxy=http://127.0.0.1:1080/; export https_proxy=http://127.0.0.1:1080/;";
        uhttp = "unset http_proxy; unset https_proxy;";
      };
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

    # Fast cd command that learns your habits
    zoxide = {
      enable = true;
    };

    # terminal
    kitty = {
      enable = false;
      themeFile = "Doom_One";
      shellIntegration.mode = "no-cursor";
      settings = {
        font_family = "Fira Code";
        font_size = 16;
        cursor_shape = "block"; # 光标形状：beam、block 或 underline
        cursor_blink_interval = 0; # 禁止光标闪烁
        macos_option_as_alt = "both"; # Don't break any Alt+Key keyboard shortcuts
        allow_remote_control = "socket-only"; # password, socket-only, socket, no, yes
        listen_on = "unix:/tmp/mykitty";
      };
    };

    ghostty = {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      settings = {
        theme = "DoomOne";
        font-family = "Fira Code";
        font-size = 16;
        shell-integration-features = "no-cursor";
        cursor-style = "block";
        cursor-style-blink = false;
        macos-option-as-alt = true;
      };
    };

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
        set -g automatic-rename on
        set -g status-left "#[fg=colour33,bold][#S]#[default] "
        set -g status-right "%Y-%m-%d %H:%M %a"
        # set -g status 2
        # set -g status-format[1] '[#(tmux ls -F "##S##{?session_attached,*,}" | tr "\n" " " | sed "s/ $//" )]'

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

        # Platform-specific copy commands
        ${
          if pkgs.stdenv.hostPlatform.isDarwin then
            ''
              bind-key -T copy-mode-vi Enter send -X copy-pipe "pbcopy"
            ''
          else
            ''
              bind-key -T copy-mode-vi Enter send -X copy-pipe "xclip -i -selection clipboard"
            ''
        }
      '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      stdlib = ''
        layout_uv() {
            if [[ -d ".venv" ]]; then
                VIRTUAL_ENV="$(pwd)/.venv"
            fi

            if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
                log_status "No virtual environment exists. Executing \`uv venv\` to create one."
                uv venv
                VIRTUAL_ENV="$(pwd)/.venv"
            fi

            PATH_add "$VIRTUAL_ENV/bin"
            export UV_ACTIVE=1  # or VENV_ACTIVE=1
            export VIRTUAL_ENV
        }
      '';
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

    mpv = {
      enable = true;
      package = pkgs.mpv-unwrapped;
      bindings = {
        LEFT = "seek -5 exact";
        RIGHT = "seek 5 exact";
      };
      config = {
        hr-seek = "yes";
      };
    };

    obs-studio = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
      plugins = [ ];
    };
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
