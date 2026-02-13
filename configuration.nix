# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [ ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    fd
    eza
    htop
    tree
    zsh
  ];

  programs.zsh.enable = true;
  programs.ssh.startAgent = false;

  users.users.charlotte = {
    isNormalUser = true;
    description = "Charlotte";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = true;

  wsl.enable = true;
  wsl.defaultUser = "charlotte";
  wsl.startMenuLaunchers = true;
  wsl.wslConf.interop.appendWindowsPath = false;

  networking.hostName = "Charlie-Laptop";
  time.timeZone = "America/Chicago";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
