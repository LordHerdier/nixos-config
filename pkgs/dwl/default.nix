# pkgs/dwl/default.nix
#
# dwl with this repo's config.h and any patches dropped in ./patches.
#
# ADDING A PATCH. Put a `.patch` file in ./patches (e.g. from the dwl wiki,
# https://codeberg.org/dwl/dwl-patches) and rebuild; every file there is
# applied, in filename order, so prefix with a number if order matters.
# Patches are applied to the dwl source before ./config.h is copied over
# config.h, so a patch that changes config.def.h (new keybinds, new rules)
# does NOT reach the build by itself -- port those hunks into ./config.h too.
#
# WHEN THIS BREAKS. A nixpkgs bump to a new dwl release can make a patch fail
# to apply, or leave ./config.h behind config.def.h. Diff against the new
# config.def.h (`nix build nixpkgs#dwl.src`) and refresh the patch.

{ dwl }:

(dwl.override { configH = ./config.h; }).overrideAttrs (old: {
  patches =
    (old.patches or [ ])
    ++ (
      let
        dir = ./patches;
      in
      map (name: dir + "/${name}") (
        builtins.filter (name: builtins.match ".*\\.patch" name != null) (
          builtins.attrNames (builtins.readDir dir)
        )
      )
    );
})
