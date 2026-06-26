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
  version = "2.2.7";
  assets = {
    "x86_64-linux" = {
      url = "https://github.com/chojs23/concord/releases/download/v${version}/concord-x86_64-unknown-linux-gnu.tar.xz";
      sha256 = "e58582792d815a58a565236bdbd6dd72e13ac0e5282924a3965b9f96482051dc";
    };
    "aarch64-linux" = {
      url = "https://github.com/chojs23/concord/releases/download/v${version}/concord-aarch64-unknown-linux-gnu.tar.xz";
      sha256 = "c3921e183bee3d27d212e07d1a5becdb1112cf01bf4f63cd73e9c9de7e683dde";
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
