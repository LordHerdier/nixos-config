# home/modules/hyprland/default.nix

{ ... }:

{
  imports = [
    ./20-monitors.nix
    ./30-input.nix
    ./40-design.nix
    ./50-binds.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    extraConfig = ''
      source = ~/.local/share/ambxst/hyprland.conf
    '';

    settings.exec-once = [
      "axctl"
      "gnome-keyring-daemon --start --components=secrets,pkcs11"
    ];
  };
}
