{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./mpd.nix
    ./ssh.nix
  ];

  home.packages = with pkgs;
    [
      mum
      btop
      pulsemixer
      unstable.qmk
      unstable.rmapi
    ]
    ++ [
      inputs.remarks.packages.${pkgs.system}.default
    ];
}
