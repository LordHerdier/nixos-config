# hosts/Apthos/default.nix — gaming VM on twm (Proxmox), GPU/NVMe passed through

{ hostName, ... }:

{
  networking.hostName = hostName;

  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../modules/profiles/desktop-hyprland.nix
    ../../modules/features/nvidia.nix
    ../../modules/features/steam.nix
    ../../modules/features/sunshine.nix
    ../../modules/common/ssh.nix
  ];

  system.stateVersion = "25.11";

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/Chicago";

  console = {
    keyMap = "colemak";
  };
}
