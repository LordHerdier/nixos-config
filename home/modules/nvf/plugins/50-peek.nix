# home/modules/nvf/plugins/50-peek.nix

{ pkgs, ... }:

let
  # nixpkgs packages peek.nvim without running its `deno task build`, so
  # `public/` has only index.html + style.css and the preview server 404s
  # on everything else ("Not Found" in the browser). Build the bundle and
  # CDN assets here, as a fixed-output derivation since it needs network.
  #
  # The hash drifts with `pkgs.deno` and an unpinned deno.land punycode
  # import; expect to refresh it after a nixpkgs bump. scripts/build.js
  # never fails on a rejected download, so before trusting a new hash
  # check $out has index.html, *.bundle.js, webview.js, the two CSS
  # files, mermaid.min.js and 20 fonts/ woff2 files.
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
