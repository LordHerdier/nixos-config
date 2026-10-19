# hosts/Apthos/default.nix — gaming VM on twm (Proxmox), GPU/NVMe passed through

{ hostName, lib, ... }:

{
  networking.hostName = hostName;

  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ../../modules/profiles/desktop-gnome.nix
    ../../modules/features/nix-ld.nix
    ../../modules/profiles/dev-docker.nix
    ../../modules/features/cifs-mounts.nix
    ../../modules/features/nvidia.nix
    ../../modules/features/ollama-vulkan.nix
    ../../modules/features/open-webui.nix
    ../../modules/features/rdp.nix
    ../../modules/features/steam.nix
    ../../modules/features/sunshine.nix
    ../../modules/features/tailscale.nix
    ../../modules/features/windows-game-drives.nix
    ../../modules/features/syncthing.nix
    ../../modules/common/ssh.nix
    ../../modules/common/kmonad/kmonad.nix
  ];

  system.stateVersion = "25.11";

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    # Mirror the boot menu to the Proxmox serial0 device (qm terminal /
    # `qm set 110 -serial0 socket`) as well as the local console, so the
    # menu and early boot output are visible over `qm terminal 110` too.
    extraConfig = ''
      serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
      terminal_input --append serial
      terminal_output --append serial
    '';
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel + a getty on ttyS0, which is what Proxmox's serial0 device shows
  # up as in the guest. Keeps tty1 as the first console so the local
  # (Proxmox noVNC) console still gets boot messages too.
  boot.kernelParams = [
    "console=tty1"
    "console=ttyS0,115200n8"
  ];

  time.timeZone = "America/Chicago";

  console = {
    keyMap = "colemak";
  };

  # Use GDM instead of the SDDM that desktop-common pulls in (via the
  # desktop-gnome profile). Not a cosmetic preference:
  # modules/features/rdp.nix runs gnome-remote-desktop in system mode, and
  # GDM is the only display manager implementing the remote display factory
  # that daemon hands authenticated RDP clients to — see that module's
  # comment. Drop rdp.nix and SDDM is fine again.
  services.displayManager.sddm.enable = lib.mkForce false;
  services.displayManager.gdm = {
    enable = true;
    # GDM suspends the machine after inactivity *on the login screen*. On a
    # box only ever reached over Moonlight/RDP/Tailscale that means
    # suspending itself out of reach any time it lands back on the greeter.
    autoSuspend = false;
  };

  # Unlock the login keyring at login. gnome-keyring.enable (desktop-common)
  # only ships the daemon/D-Bus service; the login password reaches the
  # keyring only if pam_gnome_keyring is wired into the authenticating PAM
  # service. desktop-common does that for sddm, which is now off — GDM's
  # gdm-password and gdm-autologin stacks take it from pam.services.login
  # instead of having a name of their own to set it on.
  security.pam.services.login.enableGnomeKeyring = true;

  # This box is driven remotely over Sunshine/Moonlight rather than from the
  # physical console, so log straight into a GNOME session at boot —
  # otherwise Sunshine's user service never starts (it's gated on
  # graphical-session.target) and there'd be no one at the keyboard to get
  # past the greeter.
  services.displayManager.autoLogin = {
    enable = true;
    user = "charlotte";
  };
  services.displayManager.defaultSession = "gnome";

  # Autologin fires once, at boot, only -- true of GDM as it was of SDDM. If
  # GNOME Shell ever dies mid-session (e.g. the Mutter crash documented in
  # sunshine.nix, or any other cause) the greeter comes back and just sits
  # there, needing `systemctl restart display-manager` by hand (over
  # SSH/Tailscale) to get a session back. Leave it that way.
  #
  # Recorded because the temptation recurs and GDM may well grow the same
  # knob: back on SDDM, services.displayManager.sddm.autoLogin.relogin =
  # true was tried to make this self-healing -- re-autologin every time it
  # lands on the greeter instead of just once at boot. It turned into an
  # uncontrolled restart loop (125+ session starts within a minute, each
  # partially spinning up bluetoothd/wireplumber/keyring before failing)
  # once autologin itself started hitting a keyring-unlock failure: Relogin
  # has no backoff or attempt limit, so a login that fails for any reason
  # becomes an instant, silent, resource-eating retry storm instead of the
  # (recoverable, visible) stuck-at-greeter state. A quiet failure you can
  # SSH in and fix beats a loop that keeps failing faster than anyone would
  # notice.
}
