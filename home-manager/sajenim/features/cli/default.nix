{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./mpd.nix
    ./ssh.nix
    ./zsh.nix
  ];

  home.packages = with pkgs;
    [
      mum
      btop
      unstable.qmk
      unstable.rmapi
    ]
    ++ [
      inputs.remarks.packages.${pkgs.system}.default
    ];
}
