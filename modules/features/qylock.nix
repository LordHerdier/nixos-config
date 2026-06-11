# modules/features/qylock.nix

{ ... }:

{

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  programs.qylock = {
    enable = true;
    theme = "clockwork/orbital";
    sddm.enable = false;
    quickshell.enable = true;
    themeOptions = {
      osu.gameMode = "menu";
    };
  };

}
