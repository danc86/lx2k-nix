{ lib, fetchFromGitHub }:

fetchFromGitHub {
  owner = "NXP";
  repo = "qoriq-mc-binary";
  rev = "LSDK-21.08";
  sha256 = "sha256-o04FF1q8ySDBYFizSRl3ugpbJZvpfIoEGRVFyBlFB5A=";
}
