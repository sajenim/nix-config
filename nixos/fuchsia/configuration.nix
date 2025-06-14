{...}: {
  imports = [
    # Global configuartion for all our systems
    ../common/global

    # Our user configuration and optional user units
    ../common/users/sajenim
    ../common/users/sajenim/steam
    ../common/users/sajenim/xmonad

    # Optional components
    ../common/optional/yubikey.nix

    # Services
    ./services

    # Setup our hardware
    ./hardware-configuration.nix
  ];

  # Networking configuration
  networking = {
    hostName = "fuchsia";
    networkmanager.enable = true;
  };

  # Configure programs
  programs = {
    zsh.enable = true;
    # Load and unload environment variables
    direnv.enable = true;
    # Android debug bridge: communicate with devices
    adb.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
