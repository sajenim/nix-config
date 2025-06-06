{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./global
  ];

  home.packages = with pkgs;
    [
      weechat
    ]
    ++ [
      inputs.nixvim.packages.${pkgs.system}.default
    ];

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -g status off
    '';
  };
}
