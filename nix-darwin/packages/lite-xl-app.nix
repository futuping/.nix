{
  fetchurl,
  lib,
  stdenvNoCC,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lite-xl";
  version = "2.1.8";

  src = fetchurl {
    url = "https://github.com/lite-xl/lite-xl/releases/download/v${finalAttrs.version}/lite-xl-v${finalAttrs.version}-macos-arm64.dmg";
    hash = "sha256-G4rQLqV10I1lV9r/A11KxZwGklTdhdAfe9rIOc/dZuM=";
  };

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R "Lite XL.app" "$out/Applications/"
    ln -s "$out/Applications/Lite XL.app/Contents/MacOS/lite-xl" "$out/bin/lite-xl"

    runHook postInstall
  '';

  # Preserve the complete ad-hoc signature shipped by upstream.
  dontFixup = true;

  meta = {
    description = "Lightweight text editor written in Lua";
    homepage = "https://lite-xl.com/";
    changelog = "https://github.com/lite-xl/lite-xl/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "lite-xl";
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
