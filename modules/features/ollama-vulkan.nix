# modules/features/ollama-vulkan.nix
# Ollama local LLM server, Vulkan-accelerated for hosts with a GPU whose
# CUDA/ROCm build isn't worth compiling locally (e.g. Apthos: an NVIDIA GPU,
# but ollama-cuda has to compile llama.cpp with nvcc from scratch since CUDA
# builds are unfree and Hydra doesn't cache them). ollama-vulkan is plain
# free software, so it's prebuilt on cache.nixos.org — no local build at all.
# Needs `hardware.graphics.enable` for the Vulkan loader, which the desktop
# profile already turns on.

{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;

    # Listen on all interfaces so it's reachable over Tailscale; access is
    # restricted to the tailscale0 interface in the firewall below rather
    # than opened on every interface (this box's main NIC is bridged into
    # the Proxmox LAN, not just the tailnet).
    host = "0.0.0.0";

    environmentVariables = {
      # Unload an idle model from VRAM after 30 minutes of no requests
      OLLAMA_KEEP_ALIVE = "30m";
    };
  };

  networking.firewall.interfaces = {
    tailscale0.allowedTCPPorts = [ config.services.ollama.port ];
    # Open WebUI (open-webui.nix) runs in Docker and reaches Ollama via
    # host.docker.internal -> the docker0 bridge gateway. That arrives on
    # docker0, a real interface, not loopback (which the firewall trusts
    # implicitly) -- without this it's silently dropped even though curling
    # the same address from the host itself works fine.
    docker0.allowedTCPPorts = [ config.services.ollama.port ];
  };
}
