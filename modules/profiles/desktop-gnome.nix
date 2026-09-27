# modules/profiles/desktop-gnome.nix
#
# Plain GNOME Wayland session. Imports desktop-common.nix for the
# audio/display-manager/polkit/etc. infrastructure every desktop host
# needs, regardless of compositor — see that file for why those live
# separately from Hyprland's profile.
#
# Index imports this alongside desktop-hyprland.nix (GNOME for kiddo,
# Hyprland for Charlotte) and disables the SDDM this pulls in
# (services.displayManager.sddm.enable = lib.mkForce false) in favor of
# greetd + tuigreet, which is what lets its F3 picker offer both
# sessions. Apthos imports this alone and keeps SDDM.

{ ... }:

{
  imports = [ ./desktop-common.nix ];

  services.desktopManager.gnome.enable = true;
}
