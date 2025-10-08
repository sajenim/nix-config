{...}: {
  imports = [
    ./global
  ];

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -g status on
    '';
  };
}
