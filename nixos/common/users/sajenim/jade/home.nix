{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./dunst
    ./picom
  ];

  # Wezterm terminal emulator with jade configuration
  programs.wezterm = {
    enable = true;
    package = pkgs.unstable.wezterm;
    enableZshIntegration = true;
    extraConfig = builtins.readFile (
      "${inputs.self}/nixos/common/users/sajenim/jade/wezterm.lua"
    );
  };

  # X session initialization script
  home.file.".xinitrc".source =
    "${inputs.self}/nixos/common/users/sajenim/jade/xinitrc";
}
