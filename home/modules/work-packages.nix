# home/modules/work-packages.nix

{ pkgs, ... }:

{
  home.packages = (
    with pkgs;
    [
      efficient-cli
    ]
  );
}
