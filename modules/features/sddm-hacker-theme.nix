# modules/features/sddm-hacker-theme.nix

{ ... }:

{

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  programs.sddm-hacker-theme = {
    enable = true;
    videoBackground = false;
  };

}
