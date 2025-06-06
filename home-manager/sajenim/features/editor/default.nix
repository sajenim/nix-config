{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    [
      gcc
      pandoc
      python313Full
      texliveFull
    ]
    ++ [
      inputs.nixvim.packages.${pkgs.system}.default
    ];
}
