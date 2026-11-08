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
    ../../modules/features/builder-cache.nix
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
    # Mirror the boot menu to Proxmox's serial0 (`qm set 110 -serial0
    # socket`) so it shows in `qm terminal 110` as well as the console.
    extraConfig = ''
      serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
      terminal_input --append serial
      terminal_output --append serial
    '';
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel console on ttyS0 (Proxmox's serial0) too; tty1 stays so noVNC
  # still gets boot messages.
  boot.kernelParams = [
    "console=tty1"
    "console=ttyS0,115200n8"
  ];

  console = {
    keyMap = "colemak";
  };

  # GDM instead of desktop-common's SDDM, because rdp.nix needs GDM's remote
  # display factory (see that module). Drop rdp.nix and SDDM is fine again.
  services.displayManager.sddm.enable = lib.mkForce false;
  services.displayManager.gdm = {
    enable = true;
    # GDM suspends after inactivity on the greeter, which would put this
    # remote-only box out of reach.
    autoSuspend = false;
  };

  # Unlock the login keyring at login. desktop-common wires
  # pam_gnome_keyring into sddm only; GDM's gdm-password/gdm-autologin
  # stacks pick it up from pam.services.login.
  security.pam.services.login.enableGnomeKeyring = true;

  # Driven remotely over Sunshine, whose user service needs a logged-in
  # graphical session, so autologin at boot.
  services.displayManager.autoLogin = {
    enable = true;
    user = "charlotte";
  };
  services.displayManager.defaultSession = "gnome";

  # Autologin fires only once, at boot. If GNOME Shell dies mid-session the
  # greeter just sits there until `systemctl restart display-manager` over
  # SSH. Leave it that way: SDDM's autoLogin.relogin was tried and, once
  # login hit a keyring-unlock failure, became a retry storm (125+ session
  # starts a minute; no backoff or attempt limit). A stuck greeter you can
  # SSH in and fix beats a silent loop. Don't add the equivalent on GDM.
}
