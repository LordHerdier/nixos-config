# home/kiddo.nix
#
# Home Manager root for the little-sister account. Intentionally NOT a
# variant of home/charlotte.nix — that file pulls in nvf, tmux, atuin,
# gnupg and the zsh stack, none of which should be in her closure.

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
