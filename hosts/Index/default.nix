# hosts/Index/default.nix

{
  hostName,
  config,
  lib,
  pkgs,
  ...
}:

{
  networking.hostName = hostName;

  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../modules/profiles/laptop.nix
    ../../modules/profiles/dev-docker.nix
    ../../modules/profiles/desktop-hyprland.nix
    ../../modules/profiles/desktop-gnome.nix
    ../../modules/users/kiddo.nix
    ../../modules/users/rivian.nix
    ../../modules/features/parental-controls.nix
    ../../modules/common/kmonad/kmonad.nix
    ../../modules/features/steam.nix
    ../../modules/features/remote-builder.nix
    ../../modules/features/tailscale.nix
    ../../modules/features/xwayland.nix
    # ../../modules/features/systemd-boot-silent/default.nix
    ../../modules/common/ssh.nix
    ../../modules/features/fingerprint-reader.nix
    ../../modules/features/gvfs.nix
    ../../modules/features/cifs-mounts.nix
    ../../modules/features/games-mount.nix
    ../../modules/features/usbmuxd.nix
    ../../modules/features/librepods.nix
    ../../modules/features/nix-ld.nix
    ../../modules/common/fonts.nix
    ../../modules/features/syncthing.nix
    ../../modules/features/zram.nix
    ../../modules/features/framework-kmod-fix.nix
    ../../modules/features/lean-specialisation.nix
  ];

  system.stateVersion = "25.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  # run HM asynchronously — don't block user sessions at boot
  systemd.services.home-manager-charlotte = {
    before = lib.mkForce [ ];
    wantedBy = lib.mkForce [ "multi-user.target" ];
  };

  systemd.services.home-manager-rivian = {
    before = lib.mkForce [ ];
    wantedBy = lib.mkForce [ "multi-user.target" ];
  };

  systemd.services.home-manager-kiddo = {
    before = lib.mkForce [ ];
    wantedBy = lib.mkForce [ "multi-user.target" ];
  };

  # tailscale starts in the background without blocking graphical login
  systemd.services.tailscaled.before = lib.mkForce [ ];

  services.atd.enable = lib.mkForce false;
  services.openssh.startWhenNeeded = true;
  hardware.sensor.iio.enable = false;

  # greetd + tuigreet instead of the profiles' SDDM. tuigreet defaults to
  # Hyprland (start-hyprland, from programs.hyprland) but lists every
  # registered session on F3 (GNOME, dwl, gamescope Steam);
  # --remember-session keeps the last pick.
  services.displayManager.sddm.enable = lib.mkForce false;
  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --cmd start-hyprland";
  };

  # Unlock the login keyring at login (desktop-common only does it for sddm).
  security.pam.services.greetd.enableGnomeKeyring = true;

  time.timeZone = "America/Chicago";

  console = {
    keyMap = "colemak";
  };

}
