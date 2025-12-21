{...}: {
  # X11 compositor for transparency and effects
  services.picom = {
    enable = true;
    shadow = true;
    shadowExclude = ["class_g = 'dmenu'"];
    backend = "xrender";
  };
}
