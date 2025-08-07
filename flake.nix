{
  description = "Modular and reusable Nix configuration";

  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-unstable, utils, ... }@inputs:
    let
      releaseVersion = "25.05";
      
      # Support multiple systems
      forAllSystems = utils.lib.genAttrs utils.lib.defaultSystems;
      
      # Import the existing config.nix
      nixpkgsConfig = import ./config.nix;
      
      # Get system-specific packages
      pkgsFor = system: import nixpkgs {
        inherit system;
        config = nixpkgsConfig;
        overlays = [ (import ./modules/overlays.nix { pkgs-unstable = unstablePkgsFor system; }) ];
      };
      
      unstablePkgsFor = system: import nixpkgs-unstable {
        inherit system;
        config = nixpkgsConfig;
      };
      
    in {
      homeConfigurations = 
        let
          system = "aarch64-darwin"; # Darwin system
          pkgs = pkgsFor system;
          pkgs-unstable = unstablePkgsFor system;
          lib = nixpkgs.lib;
          defaults = import ./modules/defaults.nix { releaseVersion = releaseVersion; };
        in
        lib.genAttrs defaults.defaultUsers (username: 
          let
            homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
            userConfig = (import ./modules/users/${username}.nix) { inherit pkgs lib; };
            packagesConfig = import ./modules/packages.nix { inherit pkgs pkgs-unstable lib system; };
            aiToolsConfig = import ./modules/ai-tools.nix { 
              inherit pkgs pkgs-unstable lib homeDirectory; 
              aiConfig = userConfig.aiConfig;
              basePythonPackages = packagesConfig.basePythonPackages;
            };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              {
                home = {
                  inherit username homeDirectory;
                  stateVersion = defaults.stateVersion;

                  packages = let
                    # Get non-Python packages from base config
                    nonPythonPackages = builtins.filter (pkg: 
                      let name = pkg.name or pkg.pname or "";
                      in !(lib.hasInfix "python" (lib.toLower name))
                    ) packagesConfig.packages;
                  in
                    nonPythonPackages ++ 
                    aiToolsConfig.aiPackages ++ 
                    [ aiToolsConfig.pythonWithAIExtensions ] ++
                    userConfig.extraPackages;
                  shellAliases = (import ./modules/shell.nix { inherit pkgs defaults system username; }).shellAliases // 
                                aiToolsConfig.aiAliases // 
                                userConfig.extraAliases;
                  sessionVariables = (import ./modules/languages.nix { inherit pkgs homeDirectory; }).sessionVariables // 
                                    aiToolsConfig.aiSessionVariables // 
                                    userConfig.extraSessionVariables;
                  sessionPath = (import ./modules/languages.nix { inherit pkgs homeDirectory; }).sessionPath ++ 
                               aiToolsConfig.aiSessionPath;
                };

                programs = {
                  go = (import ./modules/languages.nix { inherit pkgs homeDirectory; }).go;
                  zsh = (import ./modules/shell.nix { inherit pkgs defaults system username; }).zsh;
                  fzf = (import ./modules/shell.nix { inherit pkgs defaults system username; }).fzf;
                  home-manager.enable = true;
                };

                # Activation scripts
                home.activation.rustup = home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
                  # Check if rustup is available and set default stable if no default is set
                  if command -v rustup >/dev/null 2>&1; then
                    if ! rustup show active-toolchain >/dev/null 2>&1; then
                      echo "Setting up Rust stable toolchain..."
                      $DRY_RUN_CMD rustup default stable
                    fi
                  fi
                '';

                nixpkgs.config = nixpkgsConfig;
              }
            ];
          }
        );
    };
}
