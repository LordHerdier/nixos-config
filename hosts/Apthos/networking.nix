# hosts/Apthos/networking.nix

{ pkgs, ... }:

{
  networking = {
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

    networkmanager.enable = true;
  };

  # tailscale runs with --accept-routes, so the 192.168.50.0/24 route that
  # the subnet router advertises lands in tailscale's table 52 (rule 5270)
  # and apthos starts sending replies for its *own* LAN into tailscale0.
  # Connections arriving via the subnet router (SNATed to its LAN IP) then
  # never get an answer. Look the LAN up in `main` first so it stays
  # on-link; the private VLAN routes in table 52 are untouched.
  systemd.services.lan-policy-rule = {
    description = "Prefer the local LAN over tailscale-accepted routes";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = [
        "-${pkgs.iproute2}/bin/ip rule del to 192.168.50.0/24 lookup main priority 5000"
        "${pkgs.iproute2}/bin/ip rule add to 192.168.50.0/24 lookup main priority 5000"
      ];
      ExecStop = "-${pkgs.iproute2}/bin/ip rule del to 192.168.50.0/24 lookup main priority 5000";
    };
  };
}
