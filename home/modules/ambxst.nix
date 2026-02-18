# home/modules/ambxst.nix

{ config, ... }:

{
  xdg.cacheFile."ambxst/wallpapers.json".text = ''
    {
      "currentWall": "",
      "wallPath": "${config.home.homeDirectory}/Pictures/Wallpapers",
      "matugenScheme": "scheme-tonal-spot",
      "activeColorPreset": "",
      "tintEnabled": false
    }
  '';
}

