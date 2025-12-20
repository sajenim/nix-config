{pkgs, ...}: {
  # Enable necessary udev rules.
  services.udev.packages = with pkgs; [
    openrgb
    unstable.qmk-udev-rules
  ];
}
