# hosts/Index/networking.nix

{ ... }:

{
  systemd.services.NetworkManager-wait-online.enable = false;

  networking = {
    # Upstream router advertises IPv6 it doesn't actually route, so apps that
    # prefer AAAA records (e.g. spotify_player's dealer websocket) hang on a
    # dead IPv6 path. Disable IPv6 here until the upstream routing is fixed.
    enableIPv6 = false;

    nameservers = [
      "192.168.50.123"
      "1.1.1.1"
      "146.163.252.126"
      "146.163.252.127"
    ];
    search = [
      "lorscapa.arpa"
      "local.lorscapa.com"
      "siue.edu"
      "id.siue.edu"
    ];

    networkmanager = {
      enable = true;

      ensureProfiles.profiles = {
        eduroam = {
          connection = {
            id = "eduroam";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "eduroam";
          };
          wifi-security = {
            key-mgmt = "wpa-eap";
          };
          "802-1x" = {
            eap = "peap";
            identity = "brennwh@siue.edu";
            phase2-auth = "mschapv2";
            # password intentionally omitted — set via nmcli after deploy
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };
    };
  };
}
