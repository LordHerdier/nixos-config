# home/modules/hacky-tts.nix

{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.hacky-tts.packages.${pkgs.system}.default
  ];
}
