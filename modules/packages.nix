{ pkgs, pkgs-unstable, lib, system }:

let
  # Base Python packages for backend development
  basePythonPackages = ps: with ps; [
    # Core Python development tools
    pip
    virtualenv
    setuptools
    wheel
    
    # Code quality and formatting
    black
    isort
    flake8
    pylint
    mypy
    autopep8
    
    # Testing
    pytest
    pytest-cov
    pytest-asyncio
    
    # Common development libraries
    requests
    pydantic
    python-dotenv
    rich
    typer
    click
    
    # Data handling
    numpy
    pandas
    
    # Web development
    fastapi
    uvicorn
    aiohttp
    
    # Database
    psycopg2
    sqlalchemy
    
    # Utilities
    pyyaml
    gitpython
    
    # Legacy/specific packages
    scapy
  ];

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
    # Python - Common backend development environment
    (python313.withPackages basePythonPackages)

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
    node2nix
    bun
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
    htop
    btop
    dive

    railway
    azure-cli
    awscli2
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
  
  # Export base Python packages for extension by other modules
  inherit basePythonPackages;
}
