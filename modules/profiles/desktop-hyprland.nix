# modules/profiles/desktop-hyprland.nix

{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
    waybar
    wofi
    wl-clipboard
    grim
    slurp
    swappy
    networkmanagerapplet
    brightnessctl
    hyprpaper
    phinger-cursors
    (python3.withPackages (
      ps: with ps; [
        dbus-python
      ]
    ))
  ];

  environment.variables = {
    XCURSOR_THEME = "phinger-cursors-light";
    XCURSOR_SIZE = "24";
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
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

    # greetd = {
    #   enable = true;
    #
    #   settings = {
    #     default_session = {
    #       command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
    #     };
    #   };
    # };
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;

  hardware.graphics.enable = true;

  # Required by Noctalia's battery / power-profile widgets
  # (previously provided as mkDefault by the Ambxst module).
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}
