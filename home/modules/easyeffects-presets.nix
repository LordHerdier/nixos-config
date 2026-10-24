# home/modules/easyeffects-presets.nix

{
  config,
  inputs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.easyeffects.presets;
in
{
  options.my.easyeffects.presets = {
    enable = mkEnableOption "the Soab42/easyeffects-presets collection as EasyEffects output presets";
  };

  config = mkIf cfg.enable {
    # Linked per-file so presets saved from the GUI can still live alongside.
    xdg.dataFile."easyeffects/output" = {
      source = "${inputs.easyeffects-presets}/json";
      recursive = true;
    };
  };
}
