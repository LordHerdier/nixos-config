# modules/features/librepods.nix
#
# LibrePods: AirPods features (ANC/transparency control, ear detection,
# battery) outside Apple's ecosystem. The nixpkgs module installs a
# cap_net_admin wrapper that only members of the librepods group can run.

{ ... }:

{
  programs.librepods.enable = true;

  users.users.charlotte.extraGroups = [ "librepods" ];

  # font-rendering.nix exports QT_STYLE_OVERRIDE=adwaita-dark for widget apps,
  # but Qt Quick Controls reads the same variable as a QML style module name.
  # No such module exists, so LibrePods' Main.qml fails to load (and the app
  # never opens the socket librepods-ctl talks to). QT_QUICK_CONTROLS_STYLE
  # does not take precedence, so override the variable for LibrePods itself.
  nixpkgs.overlays = [
    (final: prev: {
      librepods = prev.symlinkJoin {
        inherit (prev.librepods) name meta;
        paths = [ prev.librepods ];
        nativeBuildInputs = [ prev.makeBinaryWrapper ];
        postBuild = ''
          for bin in librepods librepods-ctl; do
            wrapProgram $out/bin/$bin --set QT_STYLE_OVERRIDE Fusion
          done
        '';
      };
    })
  ];
}
