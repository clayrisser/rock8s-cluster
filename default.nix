{ nixpkgs ? import <nixpkgs> {} }:

nixpkgs.stdenv.mkDerivation rec {
  name = "packages";
  LANG = "en_US.UTF-8";
  buildInputs = [
    nixpkgs.aws-iam-authenticator
    nixpkgs.awscli2
    nixpkgs.awsweeper
    nixpkgs.cloc
    nixpkgs.coreutils
    nixpkgs.gnumake42
    nixpkgs.gnused
    nixpkgs.istioctl
    nixpkgs.jq
    nixpkgs.kops
    nixpkgs.kubectl
    nixpkgs.terraform
  ];
}
