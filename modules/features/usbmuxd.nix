# modules/features/usbmuxd.nix
#
# iPhone/iPad (libimobiledevice) USB access. Enabling the service installs the
# usbmuxd daemon and the udev rules that start it on plug-in — required for the
# "Trust This Device" prompt to appear and for pairing to work.

{ pkgs, ... }:

{
  services.usbmuxd.enable = true;

  environment.systemPackages = with pkgs; [
    libimobiledevice # idevicepair, ideviceinfo, etc.
    ifuse # mount iPhone filesystem
    usbutils # lsusb
  ];
}
