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
      "deepseek-r1:8b"
      "gemma3:12b"
      "qwen3:8b"
      "llama3:8b"
    ];
  };
}
