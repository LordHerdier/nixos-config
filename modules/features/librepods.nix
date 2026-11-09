# modules/features/librepods.nix
#
# LibrePods: AirPods features (ANC/transparency control, ear detection,
# battery) outside Apple's ecosystem. The nixpkgs module installs a
# cap_net_admin wrapper that only members of the librepods group can run.
#
# It isn't started with the session: librepods-watch starts librepods.service
# when an Apple Bluetooth device connects and stops it three minutes after the
# last one disconnects. Start it by hand with `systemctl --user start librepods`.

{ pkgs, ... }:

let
  watcher = pkgs.writers.writePython3Bin "librepods-watch" {
    libraries = [ pkgs.python3Packages.pygobject3 ];
    flakeIgnore = [
      "E501" # long lines are fine
      "E402" # gi.require_version() must run before the gi.repository import
    ];
  } (builtins.readFile ./librepods-watch.py);
in
{
  programs.librepods.enable = true;

  users.users.charlotte.extraGroups = [ "librepods" ];

  systemd.user.services = {
    librepods = {
      description = "LibrePods (AirPods control)";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        # The setcap wrapper, not the store binary: it needs cap_net_admin.
        # --hide starts it tray-only.
        ExecStart = "/run/wrappers/bin/librepods --hide";
        Restart = "no";
      };
    };

    librepods-watch = {
      description = "Start LibrePods while an Apple Bluetooth device is connected";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      path = [ pkgs.systemd ];
      serviceConfig = {
        ExecStart = "${watcher}/bin/librepods-watch";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };

  # home/modules/font-rendering.nix sets QT_STYLE_OVERRIDE=adwaita-dark, but
  # Qt Quick Controls reads it as a QML style name; none exists, so Main.qml
  # fails to load (and librepods-ctl's socket never opens).
  # QT_QUICK_CONTROLS_STYLE doesn't take precedence, so override it here.
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
