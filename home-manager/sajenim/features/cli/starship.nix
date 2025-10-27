{...}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;

      # Prompt layout
      format = "$username$hostname$directory$git_branch$git_status$character";
      right_format = "$c$direnv$haskell$bun$python$rust";

      # Always show username
      username = {
        style_user = "blue";
        style_root = "red";
        format = "[$user]($style)";
        show_always = true;
      };

      # Show hostname even when not over SSH
      hostname = {
        ssh_only = false;
        format = "[@$hostname]($style) ";
        style = "blue";
      };

      # Full path, no truncation
      directory = {
        style = "cyan";
        format = "[$path]($style) ";
        truncation_length = 0;
        truncate_to_repo = false;
      };

      # Git configuration
      git_branch.style = "purple";

      # Semantic colors for git status indicators
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

      # Vi-mode aware prompt character
      character = {
        success_symbol = "[♥](red)";
        error_symbol = "[♥](red)";
        vicmd_symbol = "[♥](blue)";
      };

      direnv.disabled = false;
    };
  };
}
