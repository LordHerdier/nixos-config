# modules/profiles/proxmox-lxc.nix — NixOS as a Proxmox LXC container
#
# Network config comes from the CT's netN in Proxmox (it applies it at
# start), so hosts using this declare none. Pair with profiles/server.nix.

{ modulesPath, ... }:

{
  imports = [ "${modulesPath}/virtualisation/proxmox-lxc.nix" ];
}
