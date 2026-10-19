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
    # mods = [
    #   "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
    # ];

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
