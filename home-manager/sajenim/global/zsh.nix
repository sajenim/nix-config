{pkgs, ...}: {
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
    dotDir = ".config/zsh";

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
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "5a81e13792a1eed4a03d2083771ee6e5b616b9ab";
          sha256 = "dPe5CLCAuuuLGRdRCt/nNruxMrP9f/oddRxERkgm1FE=";
        };
      }
    ];

    # Extra commands that should be added to '.zshrc'
    initContent = ''
      eval "$(direnv hook zsh)"
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      export PATH
      PROMPT='%F{blue}%n@%m %F{cyan}%~ %F{red}♥ %f';
    '';
  };
}
