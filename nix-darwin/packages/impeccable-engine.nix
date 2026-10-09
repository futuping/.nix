{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation {
  pname = "impeccable-engine";
  version = "0.1.5";
  src = fetchurl {
    url = "https://github.com/pbakaus/impeccable/releases/download/engine-v0.1.5/impeccable-darwin-arm64";
    sha256 = "0d48b6e16aa97664fdbe607d5da9ae320e389a1843e0ff1328f8c2530530320d";
  };
  dontUnpack = true;
  dontStrip = true;
  installPhase = ''
    install -Dm755 "$src" "$out/bin/impeccable-engine"
  '';
  meta = {
    description = "Pinned engine for the installed Impeccable design skill";
    homepage = "https://github.com/pbakaus/impeccable";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "impeccable-engine";
  };
}
