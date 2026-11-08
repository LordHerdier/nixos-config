# modules/profiles/desktop-gnome.nix
#
# Plain GNOME Wayland session, on top of desktop-common.nix.
#
# Index imports this alongside desktop-hyprland.nix (GNOME for kiddo) and
# replaces the SDDM it pulls in with greetd + tuigreet, whose F3 picker
# offers every session. Apthos imports this alone and swaps SDDM for GDM.

{ ... }:

{
  imports = [ ./desktop-common.nix ];

  services.desktopManager.gnome.enable = true;
}
