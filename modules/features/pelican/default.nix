# modules/features/pelican — Pelican game server panel + Wings node
#
# wings.nix is the node daemon; panel.nix (the web panel) comes next. A
# host that runs both on one VM imports this directory, and a node-only
# host can import ./wings.nix directly.

{
  imports = [ ./wings.nix ];
}
