# home/rivian.nix
#
# Same desktop/shell stack as charlotte (home/desktop-user.nix), under
# rivian's own identity. home/hosts/Index.nix is listed alongside this in
# parts/hosts.nix, since only charlotte gets her per-host file implicitly.

{ ... }:

{
  imports = [ ./desktop-user.nix ];

  home.username = "rivian";
  home.homeDirectory = "/home/rivian";

  # No programs.git user.name/email yet: git will ask on first commit.
}
