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
  version = "2.2.11";
  assets = {
    "x86_64-linux" = {
      url = "https://github.com/chojs23/concord/releases/download/v${version}/concord-x86_64-unknown-linux-gnu.tar.xz";
      sha256 = "7e7140f20eabfc58dcf589182df6de58a91c1ee6e90a3dd5065e0a75b63f2918";
    };
    "aarch64-linux" = {
      url = "https://github.com/chojs23/concord/releases/download/v${version}/concord-aarch64-unknown-linux-gnu.tar.xz";
      sha256 = "df4eaa28a27ebbbe29922c9e57f358c6746e4da389f235565c11d8a63d448c6c";
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
