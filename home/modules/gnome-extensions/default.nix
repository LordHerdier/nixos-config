# home/modules/gnome-extensions/default.nix
#
# Plumbing for GNOME Shell extensions, plus one file per extension. A live
# extension needs its package in home.packages, its UUID in org/gnome/shell
# enabled-extensions, and disable-user-extensions off.
#
# Those two dconf keys are shared, and two modules setting
# enabled-extensions conflict rather than merge -- so per-extension modules
# append to `my.gnome-extensions.extensions` and this file writes the keys.
# UUIDs come from passthru.extensionUuid (nixpkgs' buildGnomeExtension),
# so they can't be typo'd.

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

  # Hand-packaged extensions can lack extensionUuid; catch it at eval.
  missingUuid = filter (p: !(p ? extensionUuid)) cfg.extensions;
in
{
  imports = [
    ./dash-to-dock.nix
    ./just-perfection.nix
    ./user-themes.nix
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
