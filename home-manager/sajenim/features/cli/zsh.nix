{pkgs, config, ...}: {
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
    initContent = ''
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      export PATH
    '';
  };
}
