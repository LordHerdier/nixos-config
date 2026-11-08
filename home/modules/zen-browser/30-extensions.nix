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
      # add-on id -> AMO slug. Pywalfox lives in 45-pywalfox.nix.
      ExtensionSettings =
        builtins.mapAttrs
          (_: slug: {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
            installation_mode = "force_installed";
          })
          {
            # Privacy / blocking
            "uBlock0@raymondhill.net" = "ublock-origin";
            "CanvasBlocker@kkapsner.de" = "canvasblocker";
            "chrome-mask@overengineer.dev" = "chrome-mask";
            "gdpr@cavi.au.dk" = "consent-o-matic";
            "{c3c10168-4186-445c-9c5b-63f12b8e2c87}" = "cookie-editor";

            # Tools
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
            "addon@karakeep.app" = "karakeep";
            "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}" = "traduzir-paginas-web";
            "{00000f2a-7cde-4f20-83ed-434fcb420d71}" = "imagus";

            # Styling / scripting
            "addon@darkreader.org" = "darkreader";
            "{91aa3897-2634-4a8a-9092-279db23a7689}" = "zen-internet";
            "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = "styl-us";
            "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = "violentmonkey";

            # YouTube
            "sponsorBlocker@ajay.app" = "sponsorblock";
            "V3-eov3cv@hotmail.com" = "v3-get-old-youtube-layout";
          };

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
      extensionButtons = {
        "nav-bar" = [
          "chrome-mask@overengineer.dev"
          "uBlock0@raymondhill.net"
          "addon@darkreader.org"
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" # Bitwarden
          "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" # Violentmonkey
          "addon@karakeep.app"
        ];
      };
    };
  };
}
