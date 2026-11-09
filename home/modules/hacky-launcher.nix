# home/modules/hacky-launcher.nix

{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.hacky-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
