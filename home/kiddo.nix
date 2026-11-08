# home/kiddo.nix
#
# Home Manager root for the little-sister account. Deliberately not built
# on home/desktop-user.nix, which pulls in nvf, tmux, atuin, gnupg and the
# zsh stack.

{ ... }:

{
  imports = [
    ./profiles/kid.nix
  ];

  home.username = "kiddo";
  home.homeDirectory = "/home/kiddo";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
