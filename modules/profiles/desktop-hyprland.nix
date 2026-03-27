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

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };

    dbus = {
      enable = true;
    };

    seatd = {
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

  programs.ambxst.enable = true;
}
