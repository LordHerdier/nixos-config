# modules/common/nix.nix

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };
  nixpkgs.config = {
    allowUnfree = true;
  };

}
