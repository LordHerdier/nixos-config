# home/profiles/kid.nix
#
# Everything that makes the GNOME session kid-usable. Kept as its own
# profile (rather than hung off desktop-hyprland) so the two desktops
# never share state.

{ ... }:

{
  imports = [
    ../modules/kid/gnome.nix
    ../modules/kid/packages.nix
    ../modules/kid/firefox.nix
    ../modules/kid/steam.nix
    ../modules/kid/desktop-entries.nix
  ];
}
