{ stdenv, fetchFromGitHub, edk2, utillinux, nasm, acpica-tools, dtc }:
let
  edk2-platforms = stdenv.mkDerivation {
    name = "edk2-platforms";
    src = fetchFromGitHub {
      owner = "SolidRun";
      repo = "edk2-platforms";
      rev = "de2ef829e9f69eef255617cb536d13fa03c20dcc";
      sha256 = "00wy4494xbpqllpzjidll5cm6w5pfn9wia7m76ybyg05wmi180az";
    };
    patches = [
      ../edk2/patches/0001-Serdes-fix-integer-overflow-when-computing-Serdes-pr.patch
    ];
    buildPhase = "true";
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
    dontFixup = true;
  };
  edk2-non-osi = fetchFromGitHub {
    owner = "SolidRun";
    repo = "edk2-non-osi";
    rev = "c4f571fe0da70cafc58b90342a766da854e71572";
    sha256 = "0rrd0k3vqnmnnqizcqjvpdii9nyr6503kifm90hj3pz9a61qjf27";
  };
in
edk2.mkDerivation "${edk2-platforms}/Platform/SolidRun/LX2160aCex7/LX2160aCex7.dsc" {
  name = "tianocore-honeycomb-lx2k";
  nativeBuildInputs = [ utillinux nasm acpica-tools dtc ];
  hardeningDisable = [ "format" "stackprotector" "pic" "fortify" ];
  preBuild = ''
    export PACKAGES_PATH=${edk2}:${edk2-platforms}:${edk2-non-osi}
  '';
}
