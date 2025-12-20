{...}: {
  imports = [
    ./global
    ./features/cli
  ];

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -g status off
    '';
  };
}
