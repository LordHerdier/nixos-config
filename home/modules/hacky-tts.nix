# home/modules/hacky-tts.nix

{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.my.hackyTts;
in
{
  options.my.hackyTts.enable = mkEnableOption "hacky-tts AAC popup" // {
    default = true;
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.hacky-tts.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
