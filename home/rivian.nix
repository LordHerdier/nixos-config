# home/rivian.nix
#
# Same desktop/shell stack as charlotte (home/desktop-user.nix), under
# rivian's own identity. The per-host file (home/hosts/Index.nix) is listed
# alongside this one in flake.nix, since only charlotte gets it implicitly.

{ ... }:

{
  imports = [ ./desktop-user.nix ];

  home.username = "rivian";
  home.homeDirectory = "/home/rivian";

  # No programs.git user.name/email yet: git will ask on first commit.
}
