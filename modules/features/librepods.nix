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
  #
  # The package is the harveywuk fork, not upstream: the airpods Noctalia
  # plugin needs its status file and the ca:/onebud:/adaptive: verbs. The fork
  # keeps the sources at the repo root, so sourceRoot differs from nixpkgs.
  nixpkgs.overlays = [
    (
      final: prev:
      let
        librepods = prev.librepods.overrideAttrs (old: {
          version = "0.2.5-harveywuk";
          src = prev.fetchFromGitHub {
            owner = "harveywuk";
            repo = "librepods";
            rev = "4ed49df0b301ac3e6fba9c81dfbbb6726cc52201";
            hash = "sha256-Ygoqz5lnGMwZkys+Q4c4pyAUI0llvpGZ/ij5E91CkAg=";
          };
          sourceRoot = "source";
        });
      in
      {
        librepods = prev.symlinkJoin {
          inherit (librepods) name meta;
          paths = [ librepods ];
          nativeBuildInputs = [ prev.makeBinaryWrapper ];
          postBuild = ''
            for bin in librepods librepods-ctl; do
              wrapProgram $out/bin/$bin --set QT_STYLE_OVERRIDE Fusion
            done
          '';
        };
      }
    )
  ];
}
