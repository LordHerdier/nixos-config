# modules/common/security.nix

{ ... }:

{
  security = {
    sudo = {
      wheelNeedsPassword = true;
    };
  };
}
