# modules/features/syncthing.nix
#
# Syncs charlotte's ~/documents and ~/pictures between every host that
# imports this module (currently Index and Apthos). Device IDs are
# generated locally by each syncthing instance the first time it runs, so
# they can't be known ahead of time — `peerDevices` below gets filled in
# (and overrideDevices/overrideFolders flipped on) once both hosts have
# started syncthing and their real IDs are known.
#
# hostName is used so each host only lists its *peers* as devices, never
# itself.

{ hostName, lib, ... }:

let
  # Real device IDs, keyed by hostname. Add a host here once its
  # syncthing has run at least once (GUI -> Actions -> Show ID, or
  # `curl -s 127.0.0.1:8384/rest/system/status | jq -r .myID` with the
  # API key from configDir/config.xml).
  allDevices = {
    # Index = "...";
    # Apthos = "...";
  };

  peerDevices = lib.filterAttrs (name: _: name != hostName) allDevices;
  peerNames = lib.attrNames peerDevices;
in
{
  services.syncthing = {
    enable = true;
    user = "charlotte";
    group = "users";
    dataDir = "/home/charlotte";
    configDir = "/home/charlotte/.config/syncthing";

    # GUI only on localhost; reach it via `ssh -L 8384:localhost:8384` from
    # elsewhere rather than exposing it on the tailnet.
    guiAddress = "127.0.0.1:8384";

    settings = {
      devices = lib.mapAttrs (_: id: { inherit id; }) peerDevices;

      folders = lib.optionalAttrs (peerNames != [ ]) {
        "Documents" = {
          path = "/home/charlotte/documents";
          devices = peerNames;
        };
        "Pictures" = {
          path = "/home/charlotte/pictures";
          devices = peerNames;
        };
      };

      options = {
        urAccepted = -1;
      };
    };

    overrideDevices = true;
    overrideFolders = true;
  };

  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [
    22000
    21027
  ];
}
