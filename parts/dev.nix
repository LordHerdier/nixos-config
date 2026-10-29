{
  # perSystem is where devShells/packages/checks/formatter go
  perSystem =
    { lib, pkgs, ... }:
    let
      # The flake's own pkgs has no overlay; dwl-clangd needs the patched dwl.
      dwlPkgs = pkgs.extend (import ./overlay.nix);
    in
    {
      formatter = pkgs.nixfmt;

      # Writes pkgs/dwl/.clangd so clangd understands config.h -- see
      # pkgs/dwl/clangd.nix. Rerun after changing patches or bumping nixpkgs.
      apps.dwl-clangd = {
        type = "app";
        program = lib.getExe (
          pkgs.writeShellApplication {
            name = "dwl-clangd";
            runtimeInputs = [ pkgs.git ];
            text = ''
              dest="$(git rev-parse --show-toplevel)/pkgs/dwl/.clangd"
              install -m 644 ${dwlPkgs.dwl-clangd}/clangd.yaml "$dest"
              echo "wrote $dest"
            '';
          }
        );
      };

      devShells.default = pkgs.mkShell {
        # `secretspec run -- ...` reads secretspec.toml and injects the
        # declared secrets (via the `pass` provider) as env vars.
        packages = [
          pkgs.secretspec
          pkgs.pass
        ];
      };
    };
}
