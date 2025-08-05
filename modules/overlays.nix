{ pkgs-unstable }:

# Overlay to get latest versions from unstable channel
(final: prev: {
  # Development tools
  neovim = pkgs-unstable.neovim;
  dbmate = pkgs-unstable.dbmate;
  
  # Go
  go = pkgs-unstable.go;

  # Rust
  rustup = pkgs-unstable.rustup;

  # Java
  maven = pkgs-unstable.maven;
  gradle = pkgs-unstable.gradle;

  # Node.js ecosystem
  nodejs_22 = pkgs-unstable.nodejs_22;
  bun = pkgs-unstable.bun;
  typescript = pkgs-unstable.typescript;
  
  # Infrastructure tools  
  awscli2 = pkgs-unstable.awscli2;
})
