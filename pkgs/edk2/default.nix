{ stdenv, lib, buildPackages, fetchFromGitHub, libuuid, python38, bc }:
let
  edk2 = stdenv.mkDerivation {
    pname = "edk2-solidrun";
    version = "stable202105-lx2160acex7";
    src = fetchFromGitHub {
      owner = "SolidRun";
      repo = "edk2";
      fetchSubmodules = true;
      rev = "11f2013a093172f1f8b49a746d39c1ef228e4760";
      sha256 = "1jwbi81znvwj85cw9f9g93rxwjcsn8qpdmgv0zxfqf3w19i0ldpk";
    };

    depsBuildBuild = [ buildPackages.stdenv.cc ];
    nativeBuildInputs = [ libuuid python38 ];

    postPatch = "patchShebangs BaseTools/BinWrappers";

    makeFlags = [ "-C BaseTools" ]
      ++ lib.optional (stdenv.cc.isClang) [ "BUILD_CC=clang BUILD_CXX=clang++ BUILD_AS=clang" ];

    NIX_CFLAGS_COMPILE = "-Wno-return-type" + lib.optionalString (stdenv.cc.isGNU) " -Wno-error=stringop-truncation";

    hardeningDisable = [ "format" "fortify" ];

    installPhase = ''
      mkdir -vp $out
      mv -v BaseTools $out
      mv -v edksetup.sh $out
    '';

    enableParallelBuilding = true;

    passthru = {
      mkDerivation = projectDscPath: attrs: stdenv.mkDerivation ({
        inherit (edk2) src;

        nativeBuildInputs = [ bc python38 ] ++ attrs.nativeBuildInputs or [ ];

        prePatch = ''
          rm -rf BaseTools
          ln -sv ${edk2}/BaseTools BaseTools
        '';

        configurePhase = let
          crossPrefix =
            if stdenv.hostPlatform != stdenv.buildPlatform then
              stdenv.cc.targetPrefix
            else
              "";
        in ''
          runHook preConfigure
          export WORKSPACE="$PWD"
          export GCC5_AARCH64_PREFIX=${crossPrefix} DTCPP_PREFIX=${crossPrefix}
          . ${edk2}/edksetup.sh BaseTools
          runHook postConfigure
        '';

        buildPhase = ''
          runHook preBuild
          build -a AARCH64 -b ${attrs.releaseType or "RELEASE"} -t GCC5 -p ${projectDscPath} -n $NIX_BUILD_CORES
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mv -v Build/*/* $out
          runHook postInstall
        '';
      } // removeAttrs attrs [ "nativeBuildInputs" ]);
    };
  };
in
edk2
