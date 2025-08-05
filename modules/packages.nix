{ pkgs, pkgs-unstable, lib, system }:

let
  # Core system tools
  corePackages = with pkgs; [
    bash
    bat
    bottom
    cmake
    dasel
    fzf
    gawk
    gdu
    gnupg
    jq
    luarocks
    neofetch
    neovide
    ripgrep
    tree-sitter
    tre-command
    watchman
    wget
    xclip
    yazi
  ];

  # Development tools
  devPackages = with pkgs; [
    lazygit
    nixfmt-classic
    neovim
    tmux
    asdf-vm
  ];

  # Language runtimes and tools
  languagePackages = with pkgs; [
    # Python
    (python312.withPackages (ps: with ps; [
      virtualenv pip pylint scapy numpy psycopg2
    ]))

    # Ruby
    bundix
    (hiPrio bundler)
    ruby
    fastlane

    # Java
    zulu
    gradle
    maven

    # Go
    go
    air
    gopls
    go-task
    gotools
    golangci-lint
    go-migrate
    sqlc
    dbmate

    # Rust
    rustup

    # Node.js ecosystem
    nodejs_22
    bun
    node2nix
    nodePackages.pnpm
    nodePackages.typescript
    openapi-generator-cli
    typescript
    yarn

    # PHP
    php
    php.packages.composer

    # Other
    protobuf
  ];

  # Infrastructure and cloud tools
  infraPackages = with pkgs; [
    awscli2
    dive
    flyctl
    postgresql
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
  ];

  # Media tools
  mediaPackages = with pkgs; [
    imagemagick
    librsvg
    scrcpy
  ];

  # Platform-specific packages
  darwinPackages = lib.optionals pkgs.stdenv.isDarwin [
    pkgs.cocoapods
  ];

  linuxPackages = lib.optionals pkgs.stdenv.isLinux [
    # Add Linux-specific packages here
  ];

in {
  packages = corePackages ++ devPackages ++ languagePackages ++ 
             infraPackages ++ mediaPackages ++ darwinPackages ++ linuxPackages;
}
