# pkgs/concord.nix

{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  alsa-lib,
  libva,
  pipewire,
  opus,
}:
let
  version = "2.6.3";
  assets = {
    "x86_64-linux" = {
      url = "https://github.com/chojs23/concord/releases/download/v${version}/concord-x86_64-unknown-linux-gnu.tar.xz";
      sha256 = "678f0fe1a8ad52076a44df95514544c1f91c097fdddfc71d225a1dd739e3359f";
    };
    "aarch64-linux" = {
      url = "https://github.com/chojs23/concord/releases/download/v${version}/concord-aarch64-unknown-linux-gnu.tar.xz";
      sha256 = "a4990dbb85c62c624db81226ef186cdbb0f02bb47582c523521c2b95a78f4884";
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
    libva
    pipewire
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
