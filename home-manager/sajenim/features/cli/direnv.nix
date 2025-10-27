{
  # Automatic environment variable management per-directory
  programs.direnv = {
    enable = true;

    # Faster nix-shell integration with dependency caching
    nix-direnv.enable = true;

    # Hook into zsh
    enableZshIntegration = true;

    # Suppress logging output
    silent = true;
  };
}
