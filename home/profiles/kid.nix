# home/profiles/kid.nix
#
# Everything that makes the kid's GNOME session usable. Separate from the
# desktop profiles so her session shares no state with them.

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
