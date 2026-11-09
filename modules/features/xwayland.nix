# modules/features/xwayland.nix
#
# XWayland support for Hyprland, plus fixes for common issues with X11
# apps running under it.

{ pkgs, ... }:

{
  programs.hyprland.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    # Many X11 apps (browsers, screen-share pickers) shell out to xrandr to
    # query display geometry; without it they can misdetect monitors.
    xrandr
  ];
}
