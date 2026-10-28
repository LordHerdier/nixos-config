# home/charlotte.nix

{ ... }:

{
  imports = [ ./desktop-user.nix ];

  home.username = "charlotte";
  home.homeDirectory = "/home/charlotte";

  programs.git.settings = {
    user.email = "charlotte@whittleman.net";
    user.name = "Charlotte Whittleman";
  };
}
