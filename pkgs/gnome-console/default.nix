# pkgs/gnome-console/default.nix
#
# GNOME Console (kgx) with one upstream bug fixed. Not a fork and not a
# customisation: without it, the `custom-liveries` gsettings key that
# home/modules/oneshot-console.nix writes is read with a mistyped
# GVariant format string and silently discarded, so Console keeps GNOME's
# stock grey-blue terminal colors no matter what is in dconf. The patch
# header has the GLib criticals it produces and why there is no
# unpatched route to the same result.
#
# WHEN THIS BREAKS. A nixpkgs bump to a Console release that fixes this
# upstream will make the patch fail to apply, which is the intended
# failure mode -- drop this override and the overlay entry in flake.nix
# at that point, and oneshot-console.nix keeps working unchanged.

{ gnome-console }:

gnome-console.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./custom-liveries-dict-entry.patch ];
})
