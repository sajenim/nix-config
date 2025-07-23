{...}: {
  # Get up and running with large language models locally.
  services.ollama = {
    enable = true;

    # AMD GPU Support
    acceleration = "rocm";
    # 5700xt Support
    rocmOverrideGfx = "10.1.0";

    # Language models to install
    loadModels = [
      "llama3.1:8b"
      # Uncensored models
      "huihui_ai/gemma3-abliterated:4b"
    ];
  };
}
