# home/modules/zen-browser/default.nix
#
# Zen Browser via github:0xc000022070/zen-browser-flake's home-manager
# module, built on home-manager's mkFirefoxModule (programs.firefox
# options generally apply). Files are split by config domain:
#
#   10-policies.nix   policies.json  -- enforced, user can't change it
#   20-settings.nix   prefs.js       -- defaults, user can change them
#
# The rest is profile state. spaces, pins, containers, keyboardShortcuts,
# extensionButtons, liveFolders and spaceRouting go into state files Zen
# holds open while running: close Zen before a switch when any are
# declared, or activation warns and skips them (the switch succeeds).
{ inputs, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.beta

    ./10-policies.nix
    ./20-settings.nix
    ./30-extensions.nix
    ./40-appearance.nix
    ./45-pywalfox.nix
    ./50-search.nix
    ./60-bookmarks.nix
    ./70-containers.nix
    ./80-spaces.nix
    ./85-pins.nix
    ./90-keyboard-shortcuts.nix
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    # Launcher environment (Linux only). Upstream's own example is a GTK
    # theme override for unreadable Wayland widgets.
    # env = {
    #   GTK_THEME = "Adwaita";
    # };

    # Bridges to native apps (1Password, firefoxpwa, ...). 1Password also
    # needs ".zen-wrapped" listed in
    # /etc/1password/custom_allowed_browsers on the NixOS side.
    nativeMessagingHosts = [ ];

    # Every other file in this directory configures this one profile.
    profiles.default.id = 0;
  };
}
