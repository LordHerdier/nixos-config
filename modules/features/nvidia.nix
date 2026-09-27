# modules/features/nvidia.nix
# Proprietary NVIDIA driver, for hosts with the GPU passed through from a
# Proxmox VFIO host (no host-side nouveau/nvidia contention to worry about).

{ config, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
