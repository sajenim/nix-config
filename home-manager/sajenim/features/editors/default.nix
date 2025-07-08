{
  inputs,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs;
    [
      # Toolchains
      gcc
      jdk17
      python313

      # Typesetting
      pandoc
      texliveFull
    ]
    ++ [
      # Our personal neovim configuration.
      inputs.nixvim.packages.${pkgs.system}.default
    ]
    # Install jetbrains IDEs with plugins
    ++ (with inputs.nix-jetbrains-plugins.lib."${system}"; [
      (buildIdeWithPlugins pkgs.jetbrains "idea-ultimate" [
        "IdeaVIM"
        "gruvbox-material-dark"
      ])
    ]); # https://github.com/theCapypara/nix-jetbrains-plugins

  # Allow unfree packages for jetbrains IDEs
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "idea-ultimate"
      "idea-ultimate-with-plugins"
    ];

  # Copy our vim configuration file for jetbrains IDEs
  home.file.".ideavimrc".source = ./ideavimrc;
}
