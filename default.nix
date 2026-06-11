let
  pinnedNixpkgs = import (builtins.fetchTarball {
    url = https://github.com/NixOS/nixpkgs/archive/26.05.tar.gz;
    # Hash obtained using `nix-prefetch-url --unpack <url>`
    sha256 = "0am8xx09fx5yf2p0wb001v0jx1g5hrfb76h4r37xph378jgk7pcr";
  }) {};
in
{pkgs ? pinnedNixpkgs}: pkgs.callPackage ./derivation.nix {}
