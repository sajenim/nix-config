{
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      discord = prev.discord.override {withOpenASAR = true;};
    })
  ];

  home.packages = with pkgs; [
    discord
    betterdiscordctl
  ];
}
