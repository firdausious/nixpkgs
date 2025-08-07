{ pkgs, defaults, system, username }:

{
  # Shell aliases
  shellAliases = {
    # Nix flake management
    flakeup = "nix flake update ${defaults.nixConfigDirectory} --update-input";
    nxb = "nix build ${defaults.nixConfigDirectory}/#homeConfigurations.${system}.${username}.activationPackage -o ${defaults.nixConfigDirectory}/result --extra-experimental-features nix-command --extra-experimental-features flakes";
    nxa = "${defaults.nixConfigDirectory}/result/activate switch --flake ${defaults.nixConfigDirectory}/#homeConfigurations.${system}.${username}";
    
    # Home Manager with explicit flake path (unified directory approach)
    hm-switch = "home-manager switch --flake ${defaults.nixConfigDirectory}#${username}";
    hm-build = "home-manager build --flake ${defaults.nixConfigDirectory}#${username}";
    hm-news = "home-manager news --flake ${defaults.nixConfigDirectory}";
    
    # Nix flake shortcuts
    flake-show = "cd ${defaults.nixConfigDirectory} && nix flake show";
    flake-check = "cd ${defaults.nixConfigDirectory} && nix flake check";
  };

  # ZSH configuration
  zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "dotenv"
        "jsontools"
        "web-search"
        "colored-man-pages"
        "common-aliases"
        "copypath"
        "copyfile"
      ];
    };
    
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
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
  };

  # FZF configuration
  fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --follow --exclude node_modules --exclude .git --exclude Pods";
    defaultOptions = [
      "--ansi"
      "--preview-window 'right:60%' --preview 'bat'"
    ];
  };
}
