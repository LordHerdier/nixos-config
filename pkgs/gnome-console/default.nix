# pkgs/gnome-console/default.nix
#
# GNOME Console (kgx) with one upstream bug fixed: the `custom-liveries`
# gsettings key that home/modules/oneshot-console.nix writes is read with a
# mistyped GVariant format string and silently discarded, so Console keeps
# its stock colours. The patch header has the GLib criticals and why there
# is no unpatched route to the same result.
#
# WHEN THIS BREAKS. Once a Console release fixes this the patch fails to
# apply, by design: drop this override and its parts/overlay.nix entry.

{ gnome-console }:

gnome-console.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./custom-liveries-dict-entry.patch ];
})
