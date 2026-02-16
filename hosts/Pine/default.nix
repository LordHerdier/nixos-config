# hosts/Pine/default.nix

{ hostName, ... }:

{
  networking.hostName = hostName;

  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./ambxst.nix
    ../../modules/profiles/hyprland.nix
  ];

  system.stateVersion = "25.11";

  # laptop-only stuff (wifi, bluetooth, graphics, etc) goes here

  # Boot settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "nodev";

  # Set the timezone
  time.timeZone = "America/Chicago";

  # Set console language
  console = {
    keyMap = "colemak";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;


}
