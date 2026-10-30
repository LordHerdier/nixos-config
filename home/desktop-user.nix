# home/desktop-user.nix
#
# The full desktop/shell stack, shared by every "real" (non-kiddo) account.
# Identity (username, home dir, git name/email) lives in the per-user file.

{ hostName, isWsl, ... }:

{
  imports = [
    ./modules/theme
    ./modules/packages.nix
    ./modules/files.nix
    ./modules/git.nix
    ./modules/nvf
    ./modules/gnupg.nix
    ./modules/atuin.nix
    ./modules/zsh
    ./modules/tmux
    ./modules/spotify-player.nix
    ./modules/wiremix.nix
    ./modules/case-insensitive-dirs.nix
    ./modules/zen-browser
  ];

  # System-wide color tokens. Individual apps can pin a different
  # palette through their own option (my.kitty.palette, my.nvim.palette);
  # everything else follows this.
  my.theme.default = "kanagawa";

  home.sessionVariables = {
    NIX_HOST = hostName;
    IS_WSL = if isWsl then "1" else "0";
  };

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
