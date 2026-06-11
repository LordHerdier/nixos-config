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

    settings.exec-once = [
      "noctalia-shell"
      # gnome-keyring is now started by PAM at login via
      # services.gnome.gnome-keyring.enable (system config).
      "sleep 2 && /etc/profiles/per-user/charlotte/bin/kitty zsh -i -c t"
    ];
  };
}
