{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "25.05";
  };

  home.packages = with pkgs; [
    # program languages
    clojure
    go
    nodejs
    python3
    typescript

    # lsp servers
    emacs-lsp-booster
    nixd
    alejandra # nix formatter
    lua-language-server
    pyright
    ruff # python linter
    black # python formatter
    typescript-language-server
    vscode-langservers-extracted # HTML/CSS/JSON/ESLint language servers
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
    mise # manage jdks
    aider-chat
    ffmpegthumbnailer # Lightweight video thumbnailer
    mediainfo # Supplies technical and tag information about a video or audio file
    imagemagick # Software suite to create, edit, compose, or convert bitmap images
    fd
    bat # Cat(1) clone with syntax highlighting and Git integration
    xclip # Tool to access the X clipboard from a console application

    # others
    # firefox-devedition
    google-chrome
    telegram-desktop
  ];

  home.file = {
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      plugins = [
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
      ];

      shellAliases = {
        ls = "ls --color=auto --group-directories-first";
        ll = "ls -l";
        la = "ls -a";
        mg = "mvn archetype:generate";
        shttp = "export http_proxy=http://127.0.0.1:1080/; export https_proxy=http://127.0.0.1:1080/;";
        uhttp = "unset http_proxy; unset https_proxy;";
      };

      # add to ~/.zshrc
      initExtra = ''
        [ -f ~/.orbstack/shell/init.zsh ] && source ~/.orbstack/shell/init.zsh 2>/dev/null || :
      '';

      # add to ~/.zprofile
      profileExtra = ''
      '';
    };

    # Cross-Shell Prompt
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        directory = {
          truncation_length = 3;
          fish_style_pwd_dir_length = 2;
        };
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
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
      enableZshIntegration = true;
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

    # set JAVA_HOME
    java = {
      enable = true;
      package = pkgs.jdk23;
    };
  };

  # mirror
  xdg.configFile."pip/pip.conf".text = ''
    [global]
    index-url = https://pypi.tuna.tsinghua.edu.cn/simple
    format = columns
  '';
}