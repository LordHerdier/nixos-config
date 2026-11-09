# modules/common/nix.nix

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    warn-dirty = false;
    download-buffer-size = 524288000; # 500 MiB
  };
  nixpkgs.config = {
    allowUnfree = true;
    # lutris's FHS env hardcodes gtk2, which nixpkgs now marks broken.
    # Warn instead of failing evaluation until lutris drops it upstream.
    problems.handlers."gtk+".broken = "warn";
  };

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:45" ];
  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };

}
