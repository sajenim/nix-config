{...}: {
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "master";
      user = {
        name = "jasmine";
        email = "its.jassy@pm.me";
        signingkey = "8563E358D4E8040E";
      };
      commit.gpgsign = "true";
    };
  };
}
