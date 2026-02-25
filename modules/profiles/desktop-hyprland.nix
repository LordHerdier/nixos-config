# modules/profiles/desktop-hyprland.nix

{ pkgs, ... }:

{
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
    hyprland
    (python3.withPackages (
      ps: with ps; [
        dbus-python
      ]
    ))
  ];

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

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

    greetd = {
      enable = true;

      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        };
      };
    };
  };

  security.rtkit.enable = true;

  hardware.graphics.enable = true;

}
