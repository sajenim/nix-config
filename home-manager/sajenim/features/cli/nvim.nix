{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    # Toolchain
    pkgs.direnv
    pkgs.gcc
    pkgs.pandoc
    pkgs.python313Full
    pkgs.texliveFull


    # Install our nixvim configuration for neovim.
    inputs.nixvim.packages.${pkgs.system}.default
  ];
}
