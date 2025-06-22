{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs;
    [
      # Toolchains
      gcc
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
      (buildIdeWithPlugins pkgs.jetbrains "idea-community" [
        "IdeaVIM"
        "gruvbox-material-dark"
        "eu.theblob42.idea.whichkey"
      ])
    ]); # https://github.com/theCapypara/nix-jetbrains-plugins

  # Copy our vim configuration file for jetbrains IDEs 
  home.file.".ideavimrc".source = ./ideavimrc;
}
