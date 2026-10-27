# modules/features/builder-cache.nix — use the `builder` CT on twm as a binary cache
#
# The builder (hosts/Builder) builds every host on each push and serves its
# store with harmonia, so anything it has built is a download here. This only
# adds a substituter; features/remote-builder.nix imports it and adds build
# offloading on top.

{ ... }:

{
  nix.settings = {
    substituters = [ "http://10.0.10.8:5000" ];
    trusted-public-keys = [ "builder-1:MPHoCtlo1Bgo7IWe1JPW+lNiniH8jshy4rmbmFBRro4=" ];

    # 10.0.10.0/24 is only reachable from the lan or over tailscale. Fail
    # fast when it isn't (off-network laptop, WSL) so nix falls through to
    # cache.nixos.org instead of waiting on a connect.
    connect-timeout = 5;
  };
}
