# home/modules/zen-browser/default.nix
#
# Zen Browser via the home-manager module from
# github:0xc000022070/zen-browser-flake. The module is a reskin of
# home-manager's mkFirefoxModule, so anything that works for
# programs.firefox generally works here too.
#
# The files below are split by the config domain the upstream README
# uses, because the domains are stored differently and have different
# override semantics:
#
#   10-policies.nix   policies.json  -- enforced, the user cannot change it
#   20-settings.nix   prefs.js       -- defaults, the user can change them
#
# Everything else is profile state the module writes into the profile
# directory, or into zen-sessions.jsonlz4 / the other lz4 state files.
#
# STATE FILES. spaces, pins, containers, keyboardShortcuts,
# extensionButtons, liveFolders and spaceRouting are written into
# compressed state files that Zen holds open while it runs. Close Zen
# before `nixos-rebuild switch` when any of those are declared;
# activation warns and skips otherwise (the switch itself still
# succeeds).
{ inputs, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.beta

    ./10-policies.nix
    ./20-settings.nix
    ./30-extensions.nix
    ./40-appearance.nix
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
