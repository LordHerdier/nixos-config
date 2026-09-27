# hosts/Apthos/default.nix — gaming VM on twm (Proxmox), GPU/NVMe passed through

{ hostName, ... }:

{
  networking.hostName = hostName;

  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../modules/profiles/desktop-gnome.nix
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

  # This box is driven remotely over Sunshine/Moonlight rather than from the
  # physical console, so log straight into a GNOME session at boot —
  # otherwise Sunshine's user service never starts (it's gated on
  # graphical-session.target) and there'd be no one at the keyboard to
  # unlock SDDM.
  services.displayManager.autoLogin = {
    enable = true;
    user = "charlotte";
  };
  services.displayManager.defaultSession = "gnome";
}
