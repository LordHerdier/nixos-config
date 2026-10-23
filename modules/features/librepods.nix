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
  # No such module exists, so LibrePods' Main.qml fails to load. Pin Quick
  # Controls to a built-in style.
  environment.sessionVariables.QT_QUICK_CONTROLS_STYLE = "Fusion";
}
