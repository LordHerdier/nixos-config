# modules/features/tailscale.nix

{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale = {
    enable = true;
  };

}
