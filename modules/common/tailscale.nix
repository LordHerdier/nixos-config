# modules/common/tailscale.nix

{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale = {
    enable = true;
  };
  
}

