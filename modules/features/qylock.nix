# modules/features/qylock.nix

{ ... }:

{
  programs.qylock = {
    enable = true;
    theme = "paper";
    sddmTheme = "paper";
  };

}
