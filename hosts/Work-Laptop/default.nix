# hosts/Work-Laptop/default.nix

{ hostName, ... }:

{
  networking.hostName = hostName;

  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../modules/profiles/laptop.nix
    ../../modules/profiles/dev-docker.nix
    ../../modules/profiles/desktop-hyprland.nix
    ../../modules/common/ssh.nix
    ../../modules/features/nix-ld.nix
  ];

  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set the timezone
  time.timeZone = "America/Chicago";

  # Set console language
  console = {
    keyMap = "colemak";
  };

}
