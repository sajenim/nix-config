{pkgs, ...}: {
  environment = {
    binsh = "${pkgs.bash}/bin/bash";
    shells = with pkgs; [zsh];
    systemPackages = with pkgs; [
      # Ensure home-manager is on all systems
      home-manager

      # Useful system utilities
      tree
      bc
      fd
      vim
      ranger
      htop
      scrot
      jq
      git
      nmap
      xclip
      ripgrep
      sshfs
      feh
      curl
      wget
      unzip
      p7zip
    ];

    # List of directories to be symlinked to /run/current-system/sw
    pathsToLink = ["/share/zsh"];
  };

  # System Fonts
  fonts.packages = with pkgs; [
    lmodern
  ];
}
