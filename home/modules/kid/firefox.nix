# home/modules/kid/firefox.nix
#
# Firefox with the sharp edges filed off via enterprise policies, which
# she can't turn off from inside the browser.

{ config, ... }:

{
  programs.firefox = {
    enable = true;

    # The stateVersion 26.05 default, adopted early (nothing to migrate)
    # to avoid the legacy-path warning.
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    policies = {
      # Only sets the default engine; it does not enforce SafeSearch.
      SearchEngines.Default = "DuckDuckGo";

      # No account, no sync, no way to carry a profile off the machine.
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      DisablePocket = true;
      DisableDeveloperTools = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;

      # Private windows would sidestep the history.
      DisablePrivateBrowsing = true;

      # Add-ons only from addons.mozilla.org, so a random site can't
      # throw an install prompt at her.
      InstallAddonsPermission = {
        Default = false;
        Allow = [ "https://addons.mozilla.org" ];
      };

      # force_installed: always on, can't be removed, returns if the
      # profile is wiped. Fetched from AMO on first launch, so a fresh
      # profile without network starts without it (a store-pinned .xpi
      # would need the NUR rycee firefox-addons input).
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          default_area = "menupanel";
        };
      };

      # Block permission prompts rather than ask a six-year-old.
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
