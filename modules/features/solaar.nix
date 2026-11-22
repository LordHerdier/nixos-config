# modules/features/solaar.nix
#
# Logitech MX Master 3S: inspect/tune SmartShift, hi-res wheel and ratchet
# settings stored on the mouse. Over Bluetooth the wheel was sending streams
# of small hi-res events per notch (multiple scrolls per tick).

{ pkgs, ... }:

{
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true; # installs solaar and its udev rules
  };

  environment.systemPackages = [ pkgs.solaar ];
}
