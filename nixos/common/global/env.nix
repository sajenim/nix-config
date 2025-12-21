{pkgs, ...}: {
  environment = {
    # Default shell for system scripts
    binsh = "${pkgs.bash}/bin/bash";

    # Available shells for users
    shells = with pkgs; [zsh];

    systemPackages = with pkgs; [
      # System Management
      home-manager

      # Archive & Compression
      p7zip unzip

      # Development Tools
      git jq

      # Editors
      vim

      # File Management
      fd ranger tree

      # Networking
      curl nmap sshfs wget

      # System Monitoring
      htop

      # System Utilities
      bc xclip

      # Text Processing
      ripgrep
    ];

    # List of directories to be symlinked to /run/current-system/sw
    pathsToLink = ["/share/zsh"];
  };

  # System-wide font packages
  fonts.packages = with pkgs; [
    lmodern
  ];
}
