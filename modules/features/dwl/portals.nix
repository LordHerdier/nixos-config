# modules/features/dwl/portals.nix
#
# Screen sharing and screenshots for portal clients (browsers, Discord).
# Hyprland ships its own hyprland-portals.conf; this is the dwl one,
# picked by XDG_CURRENT_DESKTOP=dwl, so the two never compete.

{ pkgs, ... }:

{
  xdg.portal = {
    wlr = {
      enable = true;
      settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };
    config.dwl = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
  };
}
