# home/modules/gnome-extensions/default.nix
#
# Plumbing for GNOME Shell extensions, plus one file per extension we
# actually use. An extension needs three separate things to be live:
#
#   1. The package in home.packages, so the extension directory lands
#      under ~/.nix-profile/share/gnome-shell/extensions, which is on
#      XDG_DATA_DIRS and so is where gnome-shell looks for it.
#   2. Its UUID listed in org/gnome/shell enabled-extensions. Shipping
#      the files does nothing on its own -- the Shell only loads what
#      this list names.
#   3. disable-user-extensions off, which is the global kill switch for
#      everything in that list.
#
# Steps 2 and 3 are the same two dconf keys for every extension, so they
# can only be written once: two modules both defining
# `dconf.settings."org/gnome/shell".enabled-extensions` is a conflict,
# not a merge. That's what this file is for -- per-extension modules
# append their package to `my.gnome-extensions.extensions` and leave the
# shared keys alone.
#
# UUIDs come from the package itself (passthru.extensionUuid, set by
# nixpkgs' buildGnomeExtension) rather than being written out by hand,
# so there's no second place to update and no way to typo a UUID into a
# silently-not-loaded extension.

{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    mkIf
    types
    filter
    getName
    concatMapStringsSep
    ;

  cfg = config.my.gnome-extensions;

  # Hand-packaged extensions (ones not generated from the e.g.o
  # scrape) can lack extensionUuid; catch that at eval time instead of
  # producing a broken enabled-extensions list.
  missingUuid = filter (p: !(p ? extensionUuid)) cfg.extensions;
in
{
  imports = [
    ./dash-to-dock.nix
    ./just-perfection.nix
  ];

  options.my.gnome-extensions = {
    extensions = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.gnomeExtensions.just-perfection ]";
      description = ''
        GNOME Shell extension packages to install and enable. Each one
        is added to home.packages and its passthru.extensionUuid is
        added to org/gnome/shell enabled-extensions.

        Per-extension modules in this directory add to this list; set it
        directly only for an extension that needs no configuration of
        its own.
      '';
    };
  };

  config = mkIf (cfg.extensions != [ ]) {
    assertions = [
      {
        assertion = missingUuid == [ ];
        message = ''
          my.gnome-extensions.extensions contains packages without a
          passthru.extensionUuid, so their UUIDs can't be derived:
            ${concatMapStringsSep ", " getName missingUuid}
          Either add extensionUuid to the package or write the UUID into
          org/gnome/shell enabled-extensions by hand.
        '';
      }
    ];

    home.packages = cfg.extensions;

    dconf.settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = map (p: p.extensionUuid) cfg.extensions;
    };
  };
}
