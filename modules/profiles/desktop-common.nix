# modules/profiles/desktop-common.nix
#
# Desktop infrastructure shared by every graphical session, whatever the
# compositor/DE: audio, display manager, polkit/rtkit, GPU accel, keyring
# unlock at login, power management. Compositor-specific bits live in the
# other desktop-*.nix profiles.

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

  # org.freedesktop.secrets (e.g. for ProtonVPN's credentials). This alone
  # does NOT unlock the login keyring; that needs pam_gnome_keyring on the
  # authenticating PAM service, below.
  services.gnome.gnome-keyring.enable = true;

  # Unlock the login keyring at SDDM login. Hosts that swap SDDM for another
  # greeter (greetd on Index, GDM on Apthos) must set this on that service.
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
