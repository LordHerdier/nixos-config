# home/modules/zen-browser/30-extensions.nix
#
# Three separate things, all extension-related:
#
#   policies.ExtensionSettings    force-install addons from AMO by id
#   policies."3rdparty"           browser.storage.managed config, for
#                                 extensions that read it (uBO does)
#   profiles.*.extensions         nixpkgs/NUR addon packages, plus a
#                                 last-resort writer for an extension's
#                                 own storage.local
#
# Prefer managed storage over extensions.settings: the latter needs
# `force`, and it disables the IndexedDB storage backend profile-wide.
#
# Addon packages come from rycee's NUR expressions, which would need a
# `firefox-addons` flake input; without it, use ExtensionSettings.
{ ... }:

{
  programs.zen-browser = {
    policies = {
      # ExtensionSettings = builtins.mapAttrs (_: pluginId: {
      #   install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
      #   installation_mode = "force_installed";
      # }) {
      #   "uBlock0@raymondhill.net" = "ublock-origin";
      # };

      # Re-asserted on every browser start, so dashboard edits revert.
      # Takes effect one restart late; uBO caches managed storage.
      # "3rdparty".Extensions."uBlock0@raymondhill.net".toOverwrite = {
      #   filterLists = [
      #     "user-filters"
      #     "ublock-filters"
      #     "ublock-badware"
      #     "ublock-privacy"
      #     "ublock-unbreak"
      #   ];
      #   filters = [ "||ads.example.org^" ];
      # };
    };

    profiles.default = {
      # extensions.packages = [ ];

      # Toolbar/sidebar placement by CustomizableUI area. Ids come from
      # about:debugging#/runtime/this-firefox. Placements merge into the
      # layout Zen saved last, so a profile that has never run Zen has
      # nothing to merge into -- launch it once, then rebuild.
      #
      #   nav-bar                   the toolbar ("pin to toolbar")
      #   unified-extensions-area   the extensions panel (default)
      #   zen-sidebar-top-buttons   sidebar, above the tabs
      #   zen-sidebar-foot-buttons  sidebar, below the tabs
      # extensionButtons = {
      #   "nav-bar" = [ "uBlock0@raymondhill.net" ];
      # };
    };
  };
}
