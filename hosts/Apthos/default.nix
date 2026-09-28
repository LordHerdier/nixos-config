# hosts/Apthos/default.nix — gaming VM on twm (Proxmox), GPU/NVMe passed through

{ hostName, ... }:

{
  networking.hostName = hostName;

  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../modules/profiles/desktop-gnome.nix
    ../../modules/profiles/dev-docker.nix
    ../../modules/features/nvidia.nix
    ../../modules/features/rdp.nix
    ../../modules/features/steam.nix
    ../../modules/features/sunshine.nix
    ../../modules/features/tailscale.nix
    ../../modules/features/windows-game-drives.nix
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

  # SDDM's autologin defaults to firing once, at boot, only. If GNOME Shell
  # ever dies mid-session (e.g. the Mutter crash documented in
  # sunshine.nix, or any other cause) SDDM falls back to its normal greeter
  # and just sits there, needing `systemctl restart display-manager` by
  # hand (over SSH/Tailscale) to get a session back.
  #
  # Tried services.displayManager.sddm.autoLogin.relogin = true to make
  # that self-healing -- SDDM re-autologins every time it lands back on the
  # greeter, instead of just once at boot. Don't: on this box that turned
  # into an uncontrolled restart loop (125+ session starts within a
  # minute, each partially spinning up bluetoothd/wireplumber/keyring
  # before failing) once autologin itself started hitting a keyring-unlock
  # failure -- SDDM's Relogin has no backoff or attempt limit, so a login
  # that fails for any reason becomes an instant, silent, resource-eating
  # retry storm instead of the (recoverable, visible) stuck-at-greeter
  # state. A quiet failure you can SSH in and fix beats a loop that keeps
  # failing faster than anyone would notice.
}
