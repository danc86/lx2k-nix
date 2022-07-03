{ tianocore, ddr-phy-bin, atf, runCommandNoCC, target ? "sd" }:
let
  atf-with-tianocore = atf.override {
    bl33 = "${tianocore}/FV/LX2160ACEX7_EFI.fd";
  };
in
runCommandNoCC "lx2k-firmware-${target}.bin" { } ''
  truncate -s 8M $out
  dd of=$out bs=512 if=${atf-with-tianocore}/lx2160acex7/bl2_auto.pbl seek=8
  dd of=$out bs=512 if=${ddr-phy-bin}/fip_ddr_all.bin seek=256 conv=notrunc
  dd of=$out bs=512 if=${atf-with-tianocore}/lx2160acex7/fip.bin seek=2048 conv=notrunc
''
