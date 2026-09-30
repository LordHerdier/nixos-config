# modules/features/syncthing.nix
#
# Syncs charlotte's ~/documents and ~/pictures between every host that
# imports this module (currently Index and Apthos).
#
# hostName is used so each host only lists its *peers* as devices, never
# itself.

{ hostName, lib, ... }:

let
  # Real device IDs, keyed by hostname. To add a new host to the mesh:
  # deploy this module to it first (with no entry here yet) so it
  # generates its own ID, fetch it with
  # `secretspec run -- curl -s -H "X-API-Key: $<HostName>" \
  #   127.0.0.1:8384/rest/system/status | jq -r .myID` (repo root, after
  # storing that host's REST API key in `pass` as syncthing/keys/<HostName>
  # — see secretspec.toml), then add it below and redeploy everywhere.
  allDevices = {
    Index = "WUNK6WK-DTXJXYT-CSCXB3Q-UADN6GB-UJJGSUM-4Y3P55P-VC7YX2V-45FMYAZ";
    Apthos = "7EZSYLY-EZNJMXC-UDCRDVK-FP5UDUH-FAT4RBI-Q63LYH3-VNTPKLO-KX2VDQH";
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
