# hosts/Apthos/default.nix — VM for QML shell development on Hyprland

{ hostName, ... }:

{
  networking.hostName = hostName;

  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../modules/profiles/desktop-hyprland.nix
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

  virtualisation.hypervGuest.enable = true;
}
