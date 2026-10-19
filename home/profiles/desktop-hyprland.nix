# home/profiles/desktop-hyprland.nix

{ ... }:

{
  imports = [
    ../modules/hyprland/default.nix
    ../modules/noctalia.nix
    ../modules/desktop-packages.nix
    ../modules/font-rendering.nix
    ../modules/kitty.nix
    ../modules/spicetify.nix
    ../modules/steam.nix
    ../modules/games.nix
    ../modules/hacky-tts.nix
    ../modules/hacky-launcher.nix
  ];

  my.kitty.enable = true;
  my.spicetify.enable = true;
}
