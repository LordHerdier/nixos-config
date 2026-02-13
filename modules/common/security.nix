# modules/security.nix

{ ... }:

{
  security = {
    sudo = {
      wheelNeedsPassword = true;
    };
  };
}
