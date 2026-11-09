# home/modules/zen-browser/40-appearance.nix
#
# Chrome styling: upstream presets, userChrome/userContent CSS, and the
# two competing mod managers.
#
# MODS. `mods` installs by UUID from the Zen theme store;
# `sine.enable` + `sine.mods` installs by directory name from the Sine
# store (Linux only) and fetches at activation. They conflict -- pick one
# per profile.
#
# CSS. Declaring userChrome replaces the preset's own import, so a preset
# that ships CSS has to be re-imported at the top of the block (see the
# catppuccin line below).
#
# This file does not read my.theme; Zen is styled by its presets/mods,
# not by the palette that governs the terminal stack.
{ ... }:

{
  programs.zen-browser.profiles.default = {
    presets = {
      # catppuccin = {
      #   enable = true;
      #   flavor = "Mocha"; # Frappe | Latte | Macchiato | Mocha
      #   accent = "Mauve";
      # };

      # Privacy/perf pref bundles, applied as mkDefault -- any entry in
      # 20-settings.nix wins over them.
      # betterfox.enable = true;
      # arkenfox.enable = true;
    };

    # UUIDs from https://zen-browser.app/mods; restart to take effect.
    mods = [
      "ad97bb70-0066-4e42-9b5f-173a5e42c6fc" # SuperPins
      "642854b5-88b4-4c40-b256-e035532109df" # Transparent Zen
    ];

    # Mod options are plain prefs (Settings > Zen Mods writes the same
    # keys). Only values that differ from each mod's preferences.json
    # defaults are listed.
    settings = {
      # SuperPins
      "uc.essentials.position" = "bottom";
      "uc.pins.legacy-layout" = true;

      # Transparent Zen -- needs both for the window itself to go clear.
      "browser.tabs.allow_transparent_browser" = true;
      "zen.widget.linux.transparency" = true;
    };

    # Mutually exclusive with `mods` above.
    # sine = {
    #   enable = true;
    #   mods = [ "Arc-2.0" ];
    # };

    # userChrome = ''
    #   @import "catppuccin/userChrome.css"; # only if the preset is on
    #
    #   #navigator-toolbox {
    #     background-color: #2b2b2b;
    #   }
    # '';

    # userContent = '''';
  };
}
