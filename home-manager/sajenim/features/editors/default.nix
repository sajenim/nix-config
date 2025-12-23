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
      inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
    # Install jetbrains IDEs with plugins
    ++ (with inputs.nix-jetbrains-plugins.lib."${pkgs.stdenv.hostPlatform.system}"; [
      (buildIdeWithPlugins pkgs.jetbrains "idea-ultimate" [
        "IdeaVIM"
        "gruvbox-material-dark"
      ])
    ]); # https://github.com/theCapypara/nix-jetbrains-plugins

  # Copy our configuration files to home directory
  home.file = {
    ".ideavimrc".source = ./ideavimrc;

    # Claude configuration (link individual items to allow Claude Code to write state files)
    ".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
    ".claude/settings.json".source = ./claude/settings.json;
    ".claude/commands".source = ./claude/commands;
  };
}
