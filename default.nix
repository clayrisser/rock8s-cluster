{ nixpkgs ? import <nixpkgs> {} }:

nixpkgs.stdenv.mkDerivation rec {
  name = "packages";
  LANG = "en_US.UTF-8";
  buildInputs = [
    nixpkgs.aws-iam-authenticator
    nixpkgs.awsweeper
    nixpkgs.cloc
    nixpkgs.coreutils
    nixpkgs.gnumake42
    nixpkgs.gnused
    nixpkgs.istioctl
    nixpkgs.jq
    nixpkgs.terraform
  ];
}
