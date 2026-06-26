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
  version = "2.2.8";
  assets = {
    "x86_64-linux" = {
      url = "https://github.com/chojs23/concord/releases/download/v${version}/concord-x86_64-unknown-linux-gnu.tar.xz";
      sha256 = "56d2ff04d07f2446c4a2d150d9391f3e8e67c74bf3c062cc5788574287b40810";
    };
    "aarch64-linux" = {
      url = "https://github.com/chojs23/concord/releases/download/v${version}/concord-aarch64-unknown-linux-gnu.tar.xz";
      sha256 = "a28e5dd72fb1399f010e0d4383dae8bcf5c3e13d46a9a097fd562b38711fc73a";
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
