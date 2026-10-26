# hosts/Builder/ci.nix — build main and open PRs of the config repo, keep results
#
# Polls GitHub (the builder is on an internal VLAN, so webhooks can't reach
# it). Anything built is a gc root and gets served by harmonia, so a later
# `nixos-rebuild switch` on a client is mostly downloads. See ci-build.sh.

{ pkgs, ... }:

{
  systemd.services.nixos-ci = {
    description = "Build nixos-config main and open PRs";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = with pkgs; [
      curl
      git
      jq
      nix
    ];
    environment = {
      CI_REPO = "LordHerdier/nixos-config";
      CI_HOSTS = "Index Pine";
    };

    serviceConfig = {
      Type = "oneshot";
      User = "nixbuild";
      StateDirectory = "nixos-ci";
      TimeoutStartSec = "4h";
      Nice = 10;
    };

    script = builtins.readFile ./ci-build.sh;
  };

  systemd.timers.nixos-ci = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnActiveSec = "1min";
      OnUnitInactiveSec = "5min";
    };
  };
}
