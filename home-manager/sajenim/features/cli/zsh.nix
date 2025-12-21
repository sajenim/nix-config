{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./direnv.nix
    ./starship.nix
  ];

  home.packages = with pkgs; [
    fzf # command-line fuzzy finder
  ];

  programs.zsh = {
    enable = true;

    # Enable extra features
    autosuggestion = {
      enable = true;
    };
    syntaxHighlighting = {
      enable = true;
    };
    enableCompletion = true;

    # Configuration directory
    dotDir = "${config.xdg.configHome}/zsh";

    shellAliases = {
      # Single letter aliases
      c = "clear";
      v = "nvim";

      # Double letter aliases
      la = "ls -a";
      ll = "ls -l";
    };

    # Install plugins
    plugins = [
      { # vi(vim) mode for ZSH
        name = "zsh-vi-mode";
        src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      }

      { # replace zsh's completion with fzf
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];

    # Extra commands that should be added to '.zshrc'
    initContent = /* sh */ ''
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      export PATH

      # Auto-set wezterm tab title based on directory
      chpwd() {
        if [[ -d .git ]]; then
          # Use git repo name
          local repo=$(basename $(git rev-parse --show-toplevel 2>/dev/null))
          wezterm cli set-tab-title "$repo" 2>/dev/null
        elif [[ $(pwd) =~ "/home/sajenim/.repositories/personal/([^/]+)" ]]; then
          # Use directory name for project dirs
          wezterm cli set-tab-title "''${match[1]}" 2>/dev/null
        fi
      }

      # Run once on shell startup
      chpwd
    '';
  };
}
