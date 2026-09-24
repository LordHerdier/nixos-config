# home/modules/nvf/plugins/50-peek.nix

{ pkgs, ... }:

let
  # peek.nvim's server serves its client bundle from Deno.mainModule's
  # directory. Upstream generates that bundle via `deno task build`
  # (main.ts/webview.ts/script.ts bundled with `deno emit`, plus a few
  # CSS/JS assets fetched from CDNs) into `public/`, but nixpkgs packages
  # the plugin without ever running that build step and instead patches
  # app.lua to run the unbundled `app/src/main.ts` directly. That leaves
  # `public/` with just index.html + style.css, so the server 404s on
  # everything else index.html references ("Not Found" in the browser).
  #
  # Fetched with network access (fixed-output derivation) since the build
  # script pulls its Deno module graph and vendored assets from the internet.
  peekAssets = pkgs.stdenvNoCC.mkDerivation {
    pname = "peek-nvim-assets";
    version = pkgs.vimPlugins.peek-nvim.version;
    src = pkgs.vimPlugins.peek-nvim.src;
    nativeBuildInputs = [ pkgs.deno ];

    buildPhase = ''
      runHook preBuild
      export DENO_DIR=$TMPDIR/deno
      export HOME=$TMPDIR
      deno run --allow-run --allow-net --allow-read --allow-write --allow-env --no-check scripts/build.js
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r public/. $out/
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-4+i/WRAlq6v5s0C5j7M6uRrKddZm0i2nXjIQINkn6K0=";
  };

  peekNvim = pkgs.vimPlugins.peek-nvim.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace lua/peek/app.lua \
        --replace-fail "'../../app/src/main.ts'," "'../../public/main.bundle.js',"
    '';

    postInstall = (old.postInstall or "") + ''
      cp -r ${peekAssets}/. $out/public/
    '';
  });
in
{
  config.vim.extraPlugins.peek-nvim = {
    package = peekNvim;
  };

  config.vim.luaConfigRC.peek-nvim = # lua
    ''
      require("peek").setup({ app = "browser" })

      vim.api.nvim_create_user_command("PeekToggle", function()
        local peek = require("peek")
        if peek.is_open() then
          peek.close()
        else
          peek.open()
        end
      end, {})
    '';

  config.vim.keymaps = [
    {
      mode = "n";
      key = "<leader>md";
      action = "<cmd>PeekToggle<CR>";
      desc = "Preview markdown";
    }
  ];
}
