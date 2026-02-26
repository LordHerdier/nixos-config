{ pkgs }:

let
  pyPkgs = pkgs.python312Packages;

  # SOLIDserverRest is usually NOT in nixpkgs; package from PyPI.
  SOLIDserverRest = pyPkgs.buildPythonPackage rec {
    pname = "solidserverrest";
    version = "2.12.3";
    format = "setuptools";

    src = pyPkgs.fetchPypi {
      inherit pname version;
      sha256 = "ccfacec629ac9432544f50c227ca795674c1e229da2d86ff219d035d544d5ead";
    };

    nativeBuildInputs = with pyPkgs; [ setuptools wheel ];

    propagatedBuildInputs = with pyPkgs; [
      requests urllib3 charset-normalizer idna certifi pysocks
      pyopenssl cryptography packaging
    ];

    doCheck = false;
  };
in
pyPkgs.buildPythonApplication {
  pname = "efficient-cli";
  version = "1.0.0";
  pyproject = true;

  src = ../efficient-src;

  build-system = with pyPkgs; [ setuptools wheel ];

  propagatedBuildInputs = with pyPkgs; [
    SOLIDserverRest
    python-dotenv
    requests
    cryptography
    certifi
    macaddress
    packaging
    keyring
  ];

  nativeBuildInputs = [ pkgs.makeWrapper ];
  postFixup = ''
    wrapProgram $out/bin/efficient \
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.pass ]}
  '';

  pythonImportsCheck = [ "efficient" ];
  doCheck = false;

  meta = with pkgs.lib; {
    description = "Efficient CLI tool for SOLIDserver management";
    license = licenses.mit;
    mainProgram = "efficient";
  };
}
