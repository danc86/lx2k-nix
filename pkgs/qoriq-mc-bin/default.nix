{ lib, fetchFromGitHub }:

fetchFromGitHub {
  owner = "NXP";
  repo = "qoriq-mc-binary";
  rev = "mc_release_10.30.0";
  sha256 = "sha256-3dB5+ugcTKzrUACUlRhcrka9/sSBjY2mT9qp2aSkbAs=";
}
