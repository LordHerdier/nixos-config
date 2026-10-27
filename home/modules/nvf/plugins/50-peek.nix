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
  #
  # The CDN assets are version-pinned upstream, but upstream's deno.json maps
  # `node:punycode` to an unpinned https://deno.land/x/punycode/punycode.js,
  # and the bundler is whatever `pkgs.deno` currently is, so main.bundle.js
  # drifts whenever either moves. Expect this hash to need refreshing after a
  # nixpkgs bump; the build never fails on its own (scripts/build.js only
  # console.errors rejected downloads), so sanity-check that $out still has
  # index.html, *.bundle.js, webview.js, the two CSS files, mermaid.min.js and
  # 20 fonts/ woff2 files before trusting a new hash.
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
    outputHash = "sha256-N3KQEM82I6Lia3BN4vHCyYtG7cI0dC0Ihcn/8bT0oms=";
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
