# modules/common/nix.nix

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    warn-dirty = false;
  };
  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:45" ];
  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };

}
