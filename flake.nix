{
  description = "Firdausious computer setup";

  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, home-manager, nixpkgs, nixpkgs-unstable, utils, ... }@inputs:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs-unstable = import nixpkgs-unstable { inherit system; };
        config.allowUnfree = true;
        overlays = [ (final: prev: {
          go = pkgs-unstable.go;
          awscli2 = pkgs-unstable.awscli2;
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
                  home.stateVersion = "25.05";
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
                        virtualenv pip pylint scapy numpy psycopg2
                      ]))

                      # ruby
                      bundix
                      (hiPrio bundler)
                      ruby
                      fastlane

                      # java
                      zulu
                      # maven
                      # gradle

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
                      nodejs_22
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

                      # vlc

                      postgresql


                      dive
                      flyctl
                      awscli2
                      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
                    ] ++ lib.optionals pkgs.stdenv.isLinux [
                      # Add packages only for Linux
                    ] ++ lib.optionals pkgs.stdenv.isDarwin [
                      # Add packages only for Darwin (MacOS)
                      cocoapods
                    ];

                  home.shellAliases = {
                    flakeup =
                      # example flakeup nixpkgs-unstable
                      "nix flake lock ${nixConfigDirectory} --update-input";
                    nxb =
                      "nix build ${nixConfigDirectory}/#homeConfigurations.${system}.${username}.activationPackage -o ${nixConfigDirectory}/result --extra-experimental-features nix-command --extra-experimental-features flakes";
                    nxa =
                      "${nixConfigDirectory}/result/activate switch --flake ${nixConfigDirectory}/#homeConfigurations.${system}.${username}";
                  };

                  home.sessionVariables = {
                    ANDROID_HOME = "$HOME/Library/Android/sdk";
                    # SONAR_PATH = "$HOME/Works/system/sonar-scanner-4.7.0.2747-macosx";
                  };

                  home.sessionPath = [
                    "$ANDROID_HOME/emulator"
                    "$ANDROID_HOME/cmdline-tools/latest/bin"
                    "$ANDROID_HOME/platform-tools"
                    "$ANDROID_HOME/build-tools/30.0.3"
                    # "$SONAR_PATH/bin"
                  ];

                  # programming language
                  programs.go.enable = true;
                  programs.go.package = pkgs.go;
                  programs.go.goPath = "${homeDirectory}/go";
                  programs.go.goBin = "${homeDirectory}/go/bin/";

                  # tools
                  programs.fzf.enable = true;
                  programs.fzf.defaultCommand = "fd --type f --hidden --follow --exclude node_modules --exclude .git --exclude Pods";
                  programs.fzf.defaultOptions = [
                    "--ansi"
                    "--preview-window 'right:60%' --preview 'bat'"
                  ];

                  programs.zsh.enable = true;
                  programs.zsh.autosuggestion.enable = true;
                  programs.zsh.syntaxHighlighting.enable = true;
                  programs.zsh.autocd = true;
                  programs.zsh.oh-my-zsh.enable = true;
                  programs.zsh.oh-my-zsh.plugins = [
                    "git"
                    "dotenv"
                    "jsontools"
                    "web-search"
                    "colored-man-pages"
                    "common-aliases"
                    "copypath"
                    "copyfile"
                  ];
                  programs.zsh.plugins = [
                    {
                      name = "zsh-nix-shell";
                      file = "nix-shell.plugin.zsh";
                      src = pkgs.fetchFromGitHub {
                        owner = "chisui";
                        repo = "zsh-nix-shell";
                       rev = "v0.5.0";
                        sha256 =
                          "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
                      };
                    }
                    {
                      name = "zsh-autosuggestions";
                      src = pkgs.fetchFromGitHub {
                        owner = "zsh-users";
                        repo = "zsh-autosuggestions";
                        rev = "v0.7.0";
                        sha256 = "1g3pij5qn2j7v7jjac2a63lxd97mcsgw6xq6k5p7835q9fjiid98";
                      };
                    }
                  ];

                  # home manager
                  programs.home-manager.enable = true;

                })
            ];
          };
        };
      });
}
