# hosts/Pine/default.nix

{ hostName, pkgs, ... }:
#{ hostName, ambxst, pkgs, ... }:

{
  networking.hostName = hostName;

  imports = [
    #   ambxst.nixosModules.default
    ./hardware-configuration.nix
    ./networking.nix
    # ./ambxst.nix
    ../../modules/profiles/hyprland.nix
    ../../modules/common/tailscale.nix
    ../../modules/common/kmonad/kmonad.nix
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

  # Enable ssh sservices
  services.openssh.enable = true;

  # Dbus
  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: with ps; [
      dbus-python
    ]))
    greetd.tuigreet
    hyprland
  ];

  services.dbus.enable = true;

  virtualisation.docker.enable = true;
  services.seatd.enable = true;

  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };  


}
