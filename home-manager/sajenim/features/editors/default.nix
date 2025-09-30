{
  inputs,
  pkgs,
  lib,
  ...
}: {
  # Add claude-code overlay to make the package available
  nixpkgs.overlays = [
    inputs.claude-code.overlays.default
  ];

  # Development tools and editors
  home.packages = with pkgs;
    [
      # Toolchains
      gcc
      jdk17
      python313

      # Typesetting
      pandoc
      texliveFull

      # AI-powered coding assistant and CLI tool
      claude-code
      unstable.mcp-nixos
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

  # Allow unfree packages for proprietary software
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
      "idea-ultimate"
      "idea-ultimate-with-plugins" 
    ];

  # Copy our configuration files to home directory
  home.file = {
    ".ideavimrc".source = ./ideavimrc;
    ".claude/settings.json".source = ./claude-settings.json;
  };
}
