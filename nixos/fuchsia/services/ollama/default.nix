{...}: {
  # Get up and running with large language models locally.
  services.ollama = {
    enable = true;

    # User and group under which to run ollama
    user = "ollama";
    group = "ollama";

    # AMD GPU Support
    acceleration = "rocm";
    # 5700xt Support
    rocmOverrideGfx = "10.1.0";

    # Language models to install
    loadModels = [
      "deepseek-r1:8b"
      "gemma3:4b"
      "qwen3:8b"
      "llama3:8b"

      # Coding models
      "qwen2.5-coder:7b"
    ];

    # Location to store models
    models = "/srv/ollama/models";
  };

  # Enable the Open-WebUI server 
  services.open-webui = {
    enable = true;
    host = "fuchsia.home.arpa";
    openFirewall = true;
  };

  # Mount our subvolume for storage of models
  fileSystems = {
    "/srv/ollama" = {
      device = "/dev/disk/by-label/data";
      fsType = "btrfs";
      options = ["subvol=srv-ollama" "compress=zstd"];
    };
  };
}
