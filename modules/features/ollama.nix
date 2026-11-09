# modules/features/ollama.nix
# Ollama local LLM server, tuned for Framework 13 AMD AI 300 (Radeon 890M)

{ pkgs, ... }:

{
  services.ollama = {
    enable = true;

    # Use ROCm for AMD iGPU acceleration (Radeon 890M, RDNA 3.5)
    package = pkgs.ollama-rocm;

    # Radeon 890M is gfx1150 (RDNA 3.5 / Strix Point)
    # Run `rocminfo | grep gfx` after boot to confirm; adjust if needed
    rocmOverrideGfx = "11.5.0";

    environmentVariables = {
      # Only keep 1 model loaded — laptop RAM is shared with iGPU
      OLLAMA_MAX_LOADED_MODELS = "1";
      # Serve 1 request at a time to avoid OOM under memory pressure
      OLLAMA_NUM_PARALLEL = "1";
      # Keep model warm for 10 minutes between requests
      OLLAMA_KEEP_ALIVE = "10m";
      # Flash attention reduces memory bandwidth usage during inference
      OLLAMA_FLASH_ATTENTION = "1";
      # Quantize the KV cache to q8_0 — good memory/quality tradeoff
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
  };
}
