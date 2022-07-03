{ stdenv
, lib
, buildPackages
, fetchgit
, python3
, gettext
, ddrSpeed
}:

assert lib.elem ddrSpeed [ 2400 2600 2900 3200 ];
let
  serdes1Protocol = "4"; # 4 = SGMII, 8 = XGMII
  serdes2Protocol = "5";
  serdes3Protocol = "2";
in
stdenv.mkDerivation rec {
  pname = "rcw-mem-${toString ddrSpeed}MHz";
  version = "LSDK-21.08";

  src = fetchgit {
    url = "https://source.codeaurora.org/external/qoriq/qoriq-components/rcw";
    rev = "refs/tags/LSDK-21.08";
    sha256 = "16h1zxrlgg9ak99q6hjxvnrwa4031knqbf4057bd6g2a496jazfm";
  };

  patches = [
    ./patches/0001-lx2160acex7-misc-RCW-files.patch
    ./patches/0002-Set-io-pads-as-GPIO.patch
    ./patches/0003-S2-enable-gen3-xspi-increase-divisor-to-28.patch
    ./patches/0004-refactor-a009531-a008851-and-a011270.patch
    ./patches/0006-lx2160a-add-SVR-check-for-a050234-to-apply-only-on-r.patch
    ./patches/0007-lx2160acex7-pcie-workarounds-and-fan-full-speed.patch
    ./patches/0008-lx2160a-add-generic-bootloc-section.patch
    ./patches/0009-lx2160acex7-remove-all-predefined-RCW-files.patch
    ./patches/0010-lx2160acex7-remove-flexspi-divisor-optimization.patch
    ./patches/0011-lx210acex7-25Gbps-retimer-and-restructure-config.patch
    ./patches/0012-lx2160acex7-adjust-lanes-e-and-f-for-25g-links.patch
    ./patches/0013-lx2160acex7-added-SERDES-bank-2-with-pcie-x8.patch
    ./patches/0014-lx2160acex7-set-correctly-sdcard-card-detect-and-wri.patch
    ./patches/0015-lx2160acex7-more-SERDES-prototocol-configurations.patch
    ./patches/0016-lx2162-som-add-customization-for-this-sku.patch
    ./patches/0017-lx2160acex7-add-SD1-mode-21-serdes-configuratin.patch
    ./patches/0018-lx2160acex7-add-SD1-8S-swapped-PLLF-PLLS-and-SD2-9.patch
    ./patches/9999-lx2160acex7-add-SD1-mode-4-serdes-configuration.patch
  ];

  nativeBuildInputs = [ python3 gettext ];

  postPatch = ''
    sed -i 's@gcc@${buildPackages.stdenv.cc}/bin/gcc@' Makefile.inc rcw.py
  '';

  preBuild = ''
    cd lx2160acex7
    mkdir -p RCW
    echo "#include <configs/lx2160a_defaults.rcwi>" > RCW/template.rcw
    echo "#include <configs/lx2160a_2000_700_${toString ddrSpeed}.rcwi>" >> RCW/template.rcw
    echo "#include <configs/lx2160a_SD1_${serdes1Protocol}.rcwi>" >> RCW/template.rcw
    echo "#include <configs/lx2160a_SD2_${serdes2Protocol}.rcwi>" >> RCW/template.rcw
    echo "#include <configs/lx2160a_SD3_${serdes3Protocol}.rcwi>" >> RCW/template.rcw
  '';

  installPhase = ''
    mkdir -p $out/lx2160acex7/RCW
    cp RCW/template.bin $out/lx2160acex7/RCW
  '';
}
