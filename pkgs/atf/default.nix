{ stdenv
, lib
, buildPackages
, fetchgit
, tianocore
, rcw
, bc
, openssl
, bootMode ? "sd"
, bl33 ? "${tianocore}/FV/LX2160ACEX7_EFI.fd"
}:

assert lib.elem bootMode [ "sd" "spi" ];
let
  atfBoot = "auto";
  isCross = stdenv.buildPlatform != stdenv.hostPlatform;
in
stdenv.mkDerivation rec {
  pname = "atf";
  version = "LSDK-21.08";

  src = fetchgit {
    url = "https://source.codeaurora.org/external/qoriq/qoriq-components/atf";
    rev = "refs/tags/LSDK-21.08";
    sha256 = "02fg6bd88p5kv0mkz87shhrc518jigsipdfq97zrndzswaax9jmr";
  };

  patches = [
    ./patches/0001-plat-nxp-Add-lx2160acex7-module-support.patch
    ./patches/0002-plat-nxp-Add-lx2162-som-support.patch
    ./patches/0003-lx2160acex7-assert-SUS_S5-GPIO-to-poweroff-the-COM.patch
    ./patches/0004-plat-nxp-lx2160a-auto-boot.patch
    ./patches/0005-lx2160a-flush-i2c-bus-before-initialising-ddr.patch
    ./patches/0006-lx2160a-flush-i2c-bus-connected-mux-channels.patch
    ./patches/0007-lx2160a-flush-i2c-buses-unconditionally.patch
  ];

  enableParallelBuilding = true;

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ bc openssl ];

  makeFlags = [
    "PLAT=lx2160acex7"
    "BL33=${bl33}"
    "RCW=${rcw}/lx2160acex7/RCW/template.bin"
    "TRUSTED_BOARD_BOOT=0"
    "GENERATE_COT=0"
    "BOOT_MODE=${atfBoot}"
    "SECURE_BOOT=false"
  ] ++ lib.optional isCross "CROSS_COMPILE=${stdenv.cc.targetPrefix}" ++ [
    "all"
    "fip"
    "pbl"
  ];

  hardeningDisable = [ "all" ];

  installPhase = ''
    mkdir -p $out/lx2160acex7
    cp -v --target-directory $out/lx2160acex7 \
      build/lx2160acex7/release/*.bin \
      build/lx2160acex7/release/*.pbl

    mkdir -p $out/bin
    cp -v tools/fiptool/fiptool $out/bin
  '';

  passthru = {
    inherit atfBoot;
  };
}
