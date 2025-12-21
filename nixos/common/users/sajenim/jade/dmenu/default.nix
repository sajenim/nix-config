{pkgs, ...}: {
  # Dynamic menu for X with gruvbox theme and custom bar height
  nixpkgs.overlays = [
    (final: prev: {
      dmenu = prev.dmenu.overrideAttrs (oldAttrs: {
        patches = [
          ./patches/dmenu-bar-height-5.2.diff
          ./patches/dmenu-gruvbox-20210329-9ae8ea5.diff
        ];
      });
    })
  ];

  environment.systemPackages = [pkgs.dmenu];
}
