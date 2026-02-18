# modules/common/kmonad.nix

{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.kmonad ];

  # Enable uinput kernel module
  boot.kernelModules = [ "uinput" ];

  # Allow user access to input and uinput
  users.groups.uinput = { };
  users.groups.input = { };

  users.users.charlotte = {
    extraGroups = [ "input" "uinput" ];
  };

  # Ensure uinput device has correct perms
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput"
    KERNEL=="event*", MODE="0640", GROUP="input"
  '';
}

