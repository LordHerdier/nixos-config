# pkgs/concord.nix

{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  alsa-lib,
  opus,
}:
let
  version = "2.2.10";
  assets = {
    "x86_64-linux" = {
      url = "https://github.com/chojs23/concord/releases/download/v${version}/concord-x86_64-unknown-linux-gnu.tar.xz";
      sha256 = "b9297e629a792c9029645609905d79a3308c3d20a863d600188113c23d96d27d";
    };
    "aarch64-linux" = {
      url = "https://github.com/chojs23/concord/releases/download/v${version}/concord-aarch64-unknown-linux-gnu.tar.xz";
      sha256 = "d6d417c1fbf68d72506e90e7a81f12f68b5c2c4c1e8bc6d38f0ee6c6688b1592a";
    };
  };
  asset =
    assets.${stdenv.hostPlatform.system}
      or (throw "concord: unsupported platform ${stdenv.hostPlatform.system}");
  opusShared = opus.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DBUILD_SHARED_LIBS=ON" ];
  });
in
stdenv.mkDerivation {
  pname = "concord";
  inherit version;
  src = fetchurl { inherit (asset) url sha256; };
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    alsa-lib
    opusShared
    stdenv.cc.cc.lib
  ];
  installPhase = ''
    runHook preInstall
    install -Dm755 concord $out/bin/concord
    runHook postInstall
  '';
  meta = with lib; {
    description = "Terminal UI client for Discord";
    homepage = "https://github.com/chojs23/concord";
    license = licenses.gpl3Only;
    mainProgram = "concord";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
