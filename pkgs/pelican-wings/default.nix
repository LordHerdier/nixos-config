# pkgs/pelican-wings/default.nix
#
# Pelican's Wings daemon (https://github.com/pelican-dev/wings): runs game
# servers as Docker containers for the Pelican panel. Not in nixpkgs, and
# upstream's flake only has a devshell, so it's packaged here. Built the way
# upstream's Dockerfile does it: static (CGO off), stripped, with the
# version stamped into system.Version so the panel shows it.
#
# To bump: change `version`, set both hashes to lib.fakeHash, build, and
# copy in the hashes nix reports (src first, then vendorHash).
#
# Used by modules/features/pelican/wings.nix.

{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "pelican-wings";
  version = "1.0.0-rc.1";

  src = fetchFromGitHub {
    owner = "pelican-dev";
    repo = "wings";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TErlxIXSlmxPaEQLLqcHUm+Sum+pjI8hYve0CWpc6hc=";
  };

  vendorHash = "sha256-2Hs1SfCsf5JYIIRC0VHlfVzRx2e+xrSotqrfbCqMogo=";

  subPackages = [ "." ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/pelican/wings/system.Version=${finalAttrs.version}"
  ];

  # The suite expects a reachable Docker daemon and writable system paths
  # (/var/lib/pelican, /etc/pelican), neither of which exist in the sandbox.
  doCheck = false;

  meta = {
    description = "Server control plane for the Pelican game server panel";
    homepage = "https://github.com/pelican-dev/wings";
    changelog = "https://github.com/pelican-dev/wings/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "wings";
    platforms = lib.platforms.linux;
  };
})
