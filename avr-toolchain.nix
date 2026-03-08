
{ lib, stdenv, patchelf,fetchzip }:

stdenv.mkDerivation rec {
  pname = "avr-toolchain";
  version = "3.7.0.518";

  src = fetchzip {
    url = "https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/avr8-gnu-toolchain-osx-${version}-darwin.any.x86_64.tar.gz";
    # Update this hash after the first build attempt
    sha256 = "JhBFmKY7K2y8gqjCwub5eJ5Hib1aU7Ybw6GWgoUfb6A=";
  };

  sourceRoot = ".";
  doConfigure = false;

  buildInputs = [ patchelf ];

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out
  '';


  # Add some basic checks
  # doCheck = true;
  # checkPhase = ''
  #   $out/bin/avr-gcc --version
  # '';
  dontPatchELF = true;
  noAuditTmpdir = true;
  dontStrip = true;

  meta = with lib; {
    description = "AVR 8-bit toolchain from Microchip";
    homepage = "https://www.microchip.com/";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.darwin;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
