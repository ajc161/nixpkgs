{ pname, version, src, openasar, meta, stdenv, binaryName, desktopName, lib, undmg }:

stdenv.mkDerivation {
  inherit pname version src meta;

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r "${desktopName}.app" $out/Applications

    runHook postInstall
  '';

  postInstall = lib.strings.optionalString (openasar != null) ''
    cp -f ${openasar} $out/Applications/${desktopName}.app/Contents/Resources/app.asar
  '';
}
