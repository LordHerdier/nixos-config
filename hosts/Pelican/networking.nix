# hosts/Pelican/networking.nix
#
# Static address on the services VLAN (vmbr20, 10.0.20.0/24), the same
# shape Ansible gives the CTs there: OPNsense gateway, pihole-infra for DNS.
# systemd-networkd rather than NetworkManager: nothing here roams, and it
# leaves Docker's bridges and veths alone (it only matches en*).

{
  networking = {
    useNetworkd = true;
    useDHCP = false;
  };

  systemd.network.networks."10-services" = {
    matchConfig.Name = "en*";
    address = [ "10.0.20.220/24" ];
    gateway = [ "10.0.20.1" ];
    dns = [ "10.0.10.2" ];
    networkConfig.IPv6AcceptRA = false;
  };
}
