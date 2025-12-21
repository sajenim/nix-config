{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./dmenu
  ];

  # Desktop environment packages and configuration
  environment = {
    systemPackages = [
      # Required for some XFCE/GTK stuff
      pkgs.dconf
      # Picture viewer
      pkgs.xfce.ristretto
      # Wallpaper setter
      pkgs.feh
      # Screenshot tool
      pkgs.scrot
      # GTK theme
      pkgs.unstable.gruvbox-material-gtk-theme
      # Install our XMonad and Xmobar configuration
      inputs.xmonad-config.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # Set default terminal for the desktop environment
    sessionVariables = {
      TERMINAL = "wezterm";
    };
  };

  # Programs and tools for the desktop environment
  programs = {
    # File browser
    thunar.enable = true;
    # Configuration storage system for xfce
    xfconf.enable = true;
    # Enable dconf for GTK applications
    dconf.enable = true;
  };

  # System services for the desktop environment
  services = {
    # Mount, trash, and other functionalities
    gvfs.enable = true;
    # Thumbnail support for images
    tumbler.enable = true;
  };

  # XDG desktop portal for file pickers, screen sharing, etc.
  xdg.portal = {
    enable = true;
    config.common.default = ["gtk"];
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  # Install patched fonts for the desktop environment
  fonts.packages = [
    (pkgs.stdenv.mkDerivation {
      name = "jade-fonts";
      src = "${inputs.self}/pkgs/patched-fonts";
      installPhase = ''
        mkdir -p $out/share/fonts
        cp -r $src/* $out/share/fonts/
      '';
    })
  ];

  # Configure GTK theme system-wide
  environment.etc = {
    "xdg/gtk-3.0/settings.ini".text = /* ini */ ''
      [Settings]
      gtk-theme-name=Gruvbox-Material-Dark
      gtk-icon-theme-name=Gruvbox-Material-Dark
      gtk-application-prefer-dark-theme=true
    '';
    "xdg/gtk-4.0/settings.ini".text = /* ini */ ''
      [Settings]
      gtk-theme-name=Gruvbox-Material-Dark
      gtk-icon-theme-name=Gruvbox-Material-Dark
      gtk-application-prefer-dark-theme=true
    '';
  };
}
