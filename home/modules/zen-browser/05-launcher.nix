# home/modules/zen-browser/05-launcher.nix
#
# Always launch the home-manager-managed profile. Zen reads its profile list
# from ~/.zen/profiles.ini, not the ~/.config/zen/profiles.ini home-manager
# writes, so a bare `zen-beta` opens whichever profile Zen last picked there
# instead of the declared one. `--profile` takes a path and skips the list.
#
# The shadowing `zen-beta` is hiPrio'd over the real one in the user profile.
# The desktop entry's `Exec=zen-beta %u` resolves through PATH, so links
# opened from other apps get the flag too.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.zen-browser;
  profileDir = "${cfg.configPath}/${cfg.profiles.default.path}";
in
{
  home.packages = [
    (lib.hiPrio (
      pkgs.writeShellScriptBin "zen-beta" ''
        exec ${cfg.package}/bin/zen-beta --profile ${lib.escapeShellArg profileDir} "$@"
      ''
    ))
  ];
}
