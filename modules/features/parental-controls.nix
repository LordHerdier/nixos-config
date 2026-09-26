# modules/features/parental-controls.nix
#
# malcontent + its GNOME Settings integration ("Parental Controls" under
# Users). Gives per-user app restrictions and OARS age ratings.
#
# Scope worth knowing before relying on it: malcontent gates Flatpak
# installs/launches and GNOME Software. It does NOT sandbox anything
# installed through Nix — whatever is in her home.packages or in
# environment.systemPackages just runs. The real containment for the
# kiddo account is the small package set in home/modules/kid/, not this.

{ ... }:

{
  services.malcontent.enable = true;
}
