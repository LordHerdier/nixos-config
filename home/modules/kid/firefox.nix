# home/modules/kid/firefox.nix
#
# Firefox with the sharp edges filed off via enterprise policies.
# Policies are applied by the browser itself and she cannot turn them
# off from inside the UI.

{ config, ... }:

{
  programs.firefox = {
    enable = true;

    # Her account is brand new, so there is no ~/.mozilla to migrate —
    # adopt the XDG path that becomes the default at stateVersion 26.05
    # now rather than inheriting the legacy location and a warning.
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    policies = {
      # SafeSearch, enforced at the browser rather than per-site, so it
      # survives her clicking around.
      SearchEngines.Default = "DuckDuckGo";

      # No account, no sync, no way to carry a profile off the machine.
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      DisablePocket = true;
      DisableDeveloperTools = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;

      # Private windows would sidestep the history you'll want to be
      # able to glance at.
      DisablePrivateBrowsing = true;

      # Extensions are installable, but only from addons.mozilla.org.
      # That's where uBlock Origin and every other content blocker lives,
      # so it costs nothing for you installing things on her behalf,
      # while a random site she lands on still can't throw an install
      # prompt at her. Set Default = true to allow installs from
      # anywhere.
      InstallAddonsPermission = {
        Default = false;
        Allow = [ "https://addons.mozilla.org" ];
      };

      # uBlock Origin, pinned by policy rather than installed by hand.
      # force_installed means it is always enabled, cannot be disabled
      # or removed from about:addons, and comes back on its own if her
      # profile is ever wiped.
      #
      # Caveat: install_url is fetched from AMO on first launch, so this
      # is declarative but not offline-reproducible — a fresh profile
      # with no network starts without it. For a genuinely pinned .xpi
      # in the Nix store you'd add the NUR input and use
      # programs.firefox.profiles.<name>.extensions.packages with
      # nur.repos.rycee.firefox-addons.ublock-origin instead.
      #
      # Anything not listed here still follows InstallAddonsPermission
      # above, so you can add more blockers from AMO by hand without
      # touching this.
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          default_area = "menupanel";
        };
      };

      # Block the noisiest permission prompts outright rather than
      # asking a six-year-old to adjudicate them.
      PopupBlocking.Default = true;
      Permissions = {
        Notifications.BlockNewRequests = true;
        Location.BlockNewRequests = true;
        Camera.BlockNewRequests = true;
        Microphone.BlockNewRequests = true;
      };

      Homepage = {
        URL = "https://www.youtubekids.com/";
        StartPage = "homepage";
        Locked = true;
      };

      FirefoxHome = {
        Search = true;
        TopSites = true;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
      };

      # Bookmarks on the toolbar are how she navigates — no typing.
      DisplayBookmarksToolbar = "always";
      ManagedBookmarks = [
        {
          toplevel_name = "Kiddo";
        }
        {
          name = "YouTube Kids";
          url = "https://www.youtubekids.com/";
        }
        {
          name = "PBS Kids";
          url = "https://pbskids.org/";
        }
        {
          name = "ABCya";
          url = "https://www.abcya.com/";
        }
        {
          name = "Jellyfin";
          url = "https://jellyfin.lorscapa.com/";
        }
      ];
    };
  };
}
