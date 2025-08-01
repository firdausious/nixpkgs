{ pkgs, ... }:

{
  # CI-specific packages
  packages = with pkgs; [
    # Minimal set for CI
    coreutils 
    gnused
    gawk
    gnutar
    gzip
    unzip
    wget
  ];
}
