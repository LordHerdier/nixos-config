# modules/profiles/desktop-common.nix
#
# Desktop infrastructure shared by every graphical session on a host,
# independent of which compositor/DE actually renders it: audio, the
# display manager, polkit/rtkit, GPU accel, keyring unlock at login,
# and power management. Hyprland- and GNOME-specific bits live in their
# own desktop-*.nix profile alongside this one.

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    phinger-cursors
  ];

  environment.variables = {
    XCURSOR_THEME = "phinger-cursors-light";
    XCURSOR_SIZE = "24";
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
  };

  programs.dconf.enable = true;

  # Provides the org.freedesktop.secrets D-Bus service (keyring). Apps like
  # ProtonVPN need this to store credentials. Note: enabling this alone does
  # NOT unlock the login keyring — pam_gnome_keyring must be wired into the
  # authenticating PAM service too (see enableGnomeKeyring below / per host).
  services.gnome.gnome-keyring.enable = true;

  # Hand the login password to gnome-keyring at SDDM login so the login
  # keyring is unlocked automatically. Hosts that swap SDDM for another
  # greeter (e.g. greetd on Index) must enable this on that PAM service.
  security.pam.services.sddm.enableGnomeKeyring = true;

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };

    dbus = {
      enable = true;
    };

    xserver = {
      xkb.layout = "us";
      xkb.variant = "colemak";
    };

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;

        settings.Theme = {
          CursorTheme = "phinger-cursors-light";
          CursorSize = 24;
        };
      };
    };

    upower.enable = true;
    power-profiles-daemon.enable = true;
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;

  hardware.graphics.enable = true;
}
