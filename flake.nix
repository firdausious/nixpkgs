{
  description = "Firdausious computer setup";

  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, home-manager, nixpkgs, nixpkgs-unstable, utils, ... }@inputs:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs-unstable = import nixpkgs-unstable { inherit system; };
        overlays = [ (final: prev: {
          go = pkgs-unstable.go;
          dbmate = pkgs-unstable.dbmate;
          neovim = pkgs-unstable.neovim;
          bun = pkgs-unstable.bun;
        }) ];
        pkgs = import nixpkgs { inherit overlays system; };
      in {
        homeConfigurations = {
          firdaus = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ({ pkgs, ... }:
                let
                  nixConfigDirectory = "~/.config/nixpkgs";
                  username = "firdaus";
                  homeDirectory = "/${
                      if pkgs.stdenv.isDarwin then "Users" else "home"
                    }/${username}";
                in {
                  home.stateVersion = "24.05";
                  home.username = username;
                  home.homeDirectory = homeDirectory;

                  home.packages = with pkgs;
                    [
                      cmake
                      bat
                      bash
                      bottom
                      dasel
                      jq
                      home-manager
                      gnupg
                      gdu
                      gawk
                      tre-command
                      librsvg
                      imagemagick
                      watchman
                      ripgrep
                      wget
                      xclip
                      neofetch
                      fzf
                      luarocks
                      lazygit
                      tree-sitter
                      yazi

                      nixfmt-classic
                      neovim
                      tmux
                      zsh

                      asdf-vm

                      # python
                      (python312.withPackages (ps: with ps; [
                        virtualenv pip pylint scapy numpy beautifulsoup4
                      ]))

                      # ruby
                      bundix
                      (hiPrio bundler)
                      ruby
                      fastlane

                      # go
                      go
                      air
                      gopls
                      go-task
                      gotools
                      golangci-lint
                      go-migrate
                      sqlc
                      dbmate

                      bun

                      # nodejs
                      nodejs_20
                      # (nodejs_20.withPackages (ps: with ps; [
                      #   @zendesk/zcli
                      # ]))
                      node2nix
                      nodePackages.pnpm
                      nodePackages.typescript
                      openapi-generator-cli
                      typescript
                      yarn
                      # pkgs.nodePackages."envinfo"
                      # pkgs.nodePackages."npm-check-updates"

                      protobuf

                      dive
                      flyctl
                      awscli2
                      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
                    ] ++ lib.optionals pkgs.stdenv.isLinux [
                      # Add packages only for Linux
                    ] ++ lib.optionals pkgs.stdenv.isDarwin [
                      # Add packages only for Darwin (MacOS)
                    ];

                  home.shellAliases = {
                    flakeup =
                      # example flakeup nixpkgs-unstable
                      "nix flake lock ${nixConfigDirectory} --update-input";
                    nxb =
                      "nix build ${nixConfigDirectory}/#homeConfigurations.${system}.${username}.activationPackage -o ${nixConfigDirectory}/result ";
                    nxa =
                      "${nixConfigDirectory}/result/activate switch --flake ${nixConfigDirectory}/#homeConfigurations.${system}.${username}";
                  };

                  # programming language
                  programs.go.enable = true;
                  programs.go.package = pkgs.go;
                  programs.go.goPath = "${homeDirectory}/go";
                  programs.go.goBin = "${homeDirectory}/go/bin/";

                  # tools
                  programs.zsh.enable = true;
                  programs.zsh.autosuggestion.enable = true;
                  programs.zsh.syntaxHighlighting.enable = true;
                  programs.zsh.autocd = true;
                  programs.zsh.oh-my-zsh.enable = true;
                  programs.zsh.oh-my-zsh.plugins = [ "git" ];
                  programs.zsh.oh-my-zsh.theme = "robbyrussell";
                  programs.zsh.plugins = [{
                    name = "zsh-nix-shell";
                    file = "nix-shell.plugin.zsh";
                    src = pkgs.fetchFromGitHub {
                      owner = "chisui";
                      repo = "zsh-nix-shell";
                      rev = "v0.5.0";
                      sha256 =
                        "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
                    };
                  }];

                  # home manager
                  programs.home-manager.enable = true;

                })
            ];
          };
        };
      });
}
