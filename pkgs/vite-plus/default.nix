{
  lib,
  buildNpmPackage,
  fetchurl,
  makeWrapper,
  stdenvNoCC,
  symlinkJoin,
}:
let
  version = "0.1.11";

  globalCli = stdenvNoCC.mkDerivation {
    pname = "vite-plus-global-cli";
    inherit version;

    src = fetchurl {
      url = "https://registry.npmjs.org/@voidzero-dev/vite-plus-cli-linux-x64-gnu/-/vite-plus-cli-linux-x64-gnu-${version}.tgz";
      hash = "sha512-YG6kXRoQYMXGuThiie/RMKKd0VQYxjtTdDEw54JDmxomyrZ7PL+4Ro12RpF/KyzdFyi7h/oKSKGaNzdNEF0WYw==";
    };

    sourceRoot = "package";

    installPhase = ''
      runHook preInstall

      install -Dm755 vp $out/bin/vp

      runHook postInstall
    '';
  };

  jsBundle = buildNpmPackage {
    pname = "vite-plus-js-bundle";
    inherit version;

    src = ./.;
    npmDepsHash = "sha256-4FCEZT6BlQKJHBsPiRNSFD/r1VHjG7+6YjAEF3gJ5ao=";
    dontNpmBuild = true;
    npmInstallFlags = [ "--omit=dev" ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/libexec/vite-plus
      cp package.json package-lock.json $out/libexec/vite-plus/
      cp -r node_modules $out/libexec/vite-plus/

      runHook postInstall
    '';
  };
in
symlinkJoin {
  pname = "vite-plus";
  inherit version;

  paths = [ globalCli jsBundle ];
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    rm -f $out/bin/vp
    makeWrapper ${globalCli}/bin/vp $out/bin/vp \
      --set VITE_GLOBAL_CLI_JS_SCRIPTS_DIR ${jsBundle}/libexec/vite-plus/node_modules/vite-plus/dist
  '';

  meta = {
    description = "Unified web toolchain CLI";
    homepage = "https://github.com/voidzero-dev/vite-plus";
    license = lib.licenses.mit;
    mainProgram = "vp";
    platforms = [ "x86_64-linux" ];
  };
}
