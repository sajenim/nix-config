{inputs, ...}: {
  imports = [
    # Global home-manager configuration
    ./global

    # Desktop environment (wezterm, picom, dunst, xinitrc)
    "${inputs.self}/nixos/common/users/sajenim/jade/home.nix"

    # Optional user features and applications
    ./features/cli
    ./features/desktop
    ./features/editors
    ./features/games
    ./features/printing
    ./features/university
  ];
}
