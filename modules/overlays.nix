{ pkgs-unstable }:

# Overlay to get latest versions from unstable channel
(final: prev: {
  # Development tools
  go = pkgs-unstable.go;
  neovim = pkgs-unstable.neovim;
  dbmate = pkgs-unstable.dbmate;
  
  # Node.js ecosystem
  nodejs_22 = pkgs-unstable.nodejs_22;
  bun = pkgs-unstable.bun;
  typescript = pkgs-unstable.typescript;
  
  # Infrastructure tools  
  awscli2 = pkgs-unstable.awscli2;
})
