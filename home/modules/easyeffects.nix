# home/modules/easyeffects.nix

{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.easyeffects;
in
{
  options.my.easyeffects = {
    enable = mkEnableOption "EasyEffects for PipeWire input/output processing";
  };

  config = mkIf cfg.enable {
    # Runs easyeffects in service mode so input (mic) effects are applied
    # in the background; the GUI is still available for tuning presets.
    services.easyeffects.enable = true;
  };
}
