# hosts/Pine/default.nix

{ hostName, ... }:

{
  networking.hostName = hostName;

  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../modules/profiles/laptop.nix
    ../../modules/profiles/dev-docker.nix
    ../../modules/profiles/desktop-hyprland.nix
    ../../modules/common/kmonad/kmonad.nix
    ../../modules/features/steam.nix
    ../../modules/features/tailscale.nix
    ../../modules/features/systemd-boot-silent/default.nix
  ];

  system.stateVersion = "25.11";

  # laptop-only stuff (wifi, bluetooth, graphics, etc) goes here

  # Set the timezone
  time.timeZone = "America/Chicago";

  # Set console language
  console = {
    keyMap = "colemak";
  };

  # Enable ssh sservices
  services.openssh.enable = true;

}
