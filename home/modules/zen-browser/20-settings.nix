# home/modules/zen-browser/20-settings.nix
#
# prefs.js -- plain user preferences. Written as defaults, so the browser
# UI can still override them; to pin a value use policies.Preferences in
# 10-policies.nix.
#
# Zen's own prefs are the "zen.*" tree in about:config. Quote every key
# and do not use nested attrset notation for "browser.*" -- the module
# writes the attr path verbatim.
{ ... }:

{
  programs.zen-browser.profiles.default.settings = {
    # "zen.workspaces.continue-where-left-off" = true;
    # "zen.view.compact.hide-tabbar" = true;
    # "zen.urlbar.behavior" = "float";
    # "zen.welcome-screen.seen" = true;

    # Required for the puzzle button when 30-extensions.nix declares
    # buttons in unified-extensions-area.
    # "zen.theme.hide-unified-extensions-button" = false;
  };
}
