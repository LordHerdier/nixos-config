# modules/features/ollama-vulkan.nix
# Ollama local LLM server, Vulkan-accelerated. Used instead of ollama-cuda
# because CUDA builds are unfree and not cached by Hydra (a long local nvcc
# build); ollama-vulkan comes prebuilt from cache.nixos.org. Needs
# hardware.graphics.enable (set by desktop-common) for the Vulkan loader.

{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;

    # Listen everywhere, but the firewall below only opens it on tailscale0
    # (and docker0), not the LAN NIC.
    host = "0.0.0.0";

    environmentVariables = {
      # Unload an idle model from VRAM after 30 minutes of no requests
      OLLAMA_KEEP_ALIVE = "30m";
    };
  };

  networking.firewall.interfaces = {
    tailscale0.allowedTCPPorts = [ config.services.ollama.port ];
    # Open WebUI (open-webui.nix) reaches Ollama via host.docker.internal,
    # which arrives on docker0, not loopback, so it's otherwise dropped.
    docker0.allowedTCPPorts = [ config.services.ollama.port ];
  };
}
