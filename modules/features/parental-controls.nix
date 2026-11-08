# modules/features/parental-controls.nix
#
# malcontent + its GNOME Settings integration ("Parental Controls" under
# Users). Gives per-user app restrictions and OARS age ratings.
#
# malcontent only gates Flatpak and GNOME Software; anything installed
# through Nix just runs. The real containment for kiddo is the small
# package set in home/modules/kid/.

{ ... }:

{
  services.malcontent.enable = true;
}
