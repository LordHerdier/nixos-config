# pkgs/overlay.nix

final: prev: {
  efficient-cli = final.callPackage ./efficient-cli { };
}
