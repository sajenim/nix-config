{outputs, lib, ...}: {
  imports = [
    ./zsh.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = false;
      # Centralized unfree package allowlist.
      # Note: nixpkgs.config.allowUnfreePredicate doesn't merge across modules - only the
      # last definition wins. To maintain explicit control over unfree packages, we list
      # all allowed packages here rather than scattering predicates across feature modules.
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # Editors
          "claude-code"
          "idea-ultimate"
          "idea-ultimate-with-plugins"
          # Desktop
          "discord"
        ];
    };
  };

  programs.home-manager.enable = true;

  home = {
    username = "sajenim";
    homeDirectory = "/home/sajenim";
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  systemd.user.startServices = "sd-switch";
  home.stateVersion = "22.11";
}
