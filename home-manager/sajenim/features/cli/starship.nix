{...}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Left prompt: username@hostname directory git ♥
      format = "$username$hostname$directory$git_branch$git_status$character";

      # Right prompt: language indicators
      right_format = "$c$direnv$haskell$bun$python$rust";

      # Blue username
      username = {
        style_user = "blue";
        style_root = "red";
        format = "[$user]($style)";
        show_always = true;
      };

      # Blue @hostname
      hostname = {
        ssh_only = false;
        format = "[@$hostname]($style) ";
        style = "blue";
      };

      # Cyan directory
      directory = {
        style = "cyan";
        format = "[$path]($style) ";
        truncation_length = 0;
        truncate_to_repo = false;
      };

      # Git branch (purple, no bold)
      git_branch = {
        style = "purple";
      };

      # Git status with semantic colors (no bold, no brackets)
      git_status = {
        format = "$conflicted$stashed$deleted$renamed$modified$staged$untracked$ahead_behind";
        conflicted = "[=$count](red) ";
        ahead = "[⇡$count](cyan) ";
        behind = "[⇣$count](cyan) ";
        diverged = "[⇡$ahead_count](cyan)[⇣$behind_count](cyan) ";
        untracked = "[?$count](yellow) ";
        stashed = "[\\$$count](cyan) ";
        modified = "[!$count](yellow) ";
        staged = "[+$count](green) ";
        renamed = "[»$count](cyan) ";
        deleted = "[✘$count](red) ";
      };

      # Heart prompt character (red in insert mode, blue in normal mode)
      character = {
        success_symbol = "[♥](red)";
        error_symbol = "[♥](red)";
        vicmd_symbol = "[♥](blue)";
      };

      # Language modules for right prompt (only configure non-defaults)

      # Enable direnv (disabled by default)
      direnv.disabled = false;

      # C, Python, Haskell, Bun, Rust: use defaults
    };
  };
}
