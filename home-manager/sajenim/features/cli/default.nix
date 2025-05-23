{pkgs, ...}: {
  imports = [
    ./git.nix
    ./mpd.nix
    ./nvim.nix
    ./remarkable.nix
    ./ssh.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    pulsemixer
    unstable.qmk
  ];
}
