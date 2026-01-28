# Global Home Manager configuration for user sajenim.
# This module provides base user settings, nixpkgs configuration, and core imports
# that are inherited across all hosts where this user is configured.
{outputs, lib, ...}: {
  # Nixpkgs configuration - applies overlays and sets package acceptance policy
  nixpkgs = {
    # Apply custom overlays to extend/modify the package set
    overlays = [
      outputs.overlays.additions      # Custom packages from pkgs/
      outputs.overlays.modifications  # Package patches and modifications
      outputs.overlays.unstable-packages # Unstable channel packages
    ];

    config = {
      # Default to free software only - unfree packages must be explicitly allowed
      allowUnfree = false;

      # Centralized unfree package allowlist for Home Manager user configuration.
      # Note: nixpkgs.config.allowUnfreePredicate doesn't merge across modules - only the
      # last definition wins. To maintain explicit control over unfree packages, we list
      # all allowed packages here rather than scattering predicates across feature modules.
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # Development tools
          "claude-code"
          "idea"
          "idea-with-plugins"
        ];
    };
  };

  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;

  # User identity and base configuration
  home = {
    username = "sajenim";
    homeDirectory = "/home/sajenim";
    sessionVariables = {
      EDITOR = "nvim"; # Default text editor for CLI operations
    };
    sessionPath = [
      "$HOME/.local/bin" # User scripts and executables
    ];
  };

  # Automatically restart systemd user services on configuration changes
  systemd.user.startServices = "sd-switch";

  # Home Manager state version - don't change this after initial setup
  home.stateVersion = "22.11";
}
