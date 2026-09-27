# home/profiles/desktop-gnome.nix

{ ... }:

{
  imports = [
    ../modules/desktop-files.nix
    ../modules/desktop-packages.nix
    ../modules/kitty.nix
    ../modules/steam.nix
    ../modules/games.nix
  ];

  # font-rendering.nix isn't needed here: it exists to hand GTK/Qt apps
  # antialiasing/hinting settings via GSettings/XSettings because
  # Hyprland has no session daemon to push them. GNOME's own
  # gnome-settings-daemon already does this.

  my.kitty.enable = true;
}
