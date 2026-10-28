{
  # perSystem is where devShells/packages/checks/formatter go
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt;

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
