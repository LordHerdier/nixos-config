# home/modules/semaphore-cli.nix

{ pkgs, lib, ... }:

let
  semaphore-cli = pkgs.stdenv.mkDerivation {
    pname = "semaphore-cli";
    version = "0.33.1";

    src = pkgs.fetchurl {
      url = "https://github.com/semaphoreci/cli/releases/download/v0.33.1/sem_Linux_x86_64.tar.gz";
      hash = "sha256-rvkcUVIc5EsfgSIBtGPsGxORqiPEVfKPrt8E4jfDcXY=";
    };

    sourceRoot = ".";

    installPhase = ''
      install -Dm755 sem $out/bin/sem
    '';

    meta = {
      description = "Semaphore CI/CD command-line interface";
      homepage = "https://github.com/semaphoreci/cli";
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  home.packages = [ semaphore-cli ];
}
