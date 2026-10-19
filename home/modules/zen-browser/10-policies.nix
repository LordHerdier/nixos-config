# home/modules/zen-browser/10-policies.nix
#
# policies.json -- enterprise policy, enforced; the user cannot change
# these from inside the browser. Two sub-domains live here:
#
#   top-level keys        feature switches (DisableTelemetry, ...)
#   Preferences.<key>     individual prefs pinned with Status = "locked"
#
# A pref that should only be a *default* belongs in 20-settings.nix
# instead. Reference: https://mozilla.github.io/policy-templates/
{ ... }:

{
  programs.zen-browser.policies = {
    # DisableAppUpdate = true; # see upstream #48 before enabling with 1Password
    # DisableTelemetry = true;
    # DisableFirefoxStudies = true;
    # DisablePocket = true;
    # DisableFeedbackCommands = true;
    # DontCheckDefaultBrowser = true;
    # NoDefaultBookmarks = true;
    # OfferToSaveLogins = false;
    # AutofillAddressEnabled = true;
    # AutofillCreditCardEnabled = false;

    # EnableTrackingProtection = {
    #   Value = true;
    #   Locked = true;
    #   Cryptomining = true;
    #   Fingerprinting = true;
    # };

    # Locked prefs. Keys are always quoted.
    # Preferences = {
    #   "browser.startup.homepage" = {
    #     Value = "about:blank";
    #     Status = "locked";
    #   };
    # };
  };
}
