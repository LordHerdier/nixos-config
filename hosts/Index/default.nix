# hosts/Index/default.nix

{ hostName, lib, ... }:

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
    # ../../modules/features/systemd-boot-silent/default.nix
    ../../modules/common/ssh.nix
    ../../modules/features/fingerprint-reader.nix
    ../../modules/features/gvfs.nix
    ../../modules/features/cifs-mounts.nix
  ];

  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  # run HM asynchronously — don't block user sessions at boot
  systemd.services.home-manager-charlotte = {
    before = lib.mkForce [];
    wantedBy = lib.mkForce [ "multi-user.target" ];
  };

  # tailscale starts in the background without blocking graphical login
  systemd.services.tailscaled.before = lib.mkForce [];

  services.atd.enable = lib.mkForce false;
  services.openssh.startWhenNeeded = true;
  hardware.sensor.iio.enable = false;

  # laptop-only stuff (wifi, bluetooth, graphics, etc) goes here

  # Set the timezone
  time.timeZone = "America/Chicago";

  # Set console language
  console = {
    keyMap = "colemak";
  };

}
