{pkgs, ...}: {
  imports = [
    ./cava
    ./discord
    ./mpv
    ./obs
  ];

  # Install some packages for our desktop environment
  home.packages = with pkgs; [
    firefox
    gimp
    piper
    zathura

    # KDE Packages
    kdePackages.kdenlive
  ];
}
