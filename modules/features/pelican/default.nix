# modules/features/pelican — Pelican game server panel + Wings node
#
# panel.nix is the web panel and wings.nix is the node daemon that runs the
# game servers. A host that runs both on one VM imports this directory; a
# node-only or panel-only host imports the one file it needs.

{
  imports = [
    ./panel.nix
    ./wings.nix
  ];
}
