
1. Install Nix
```
sh <(curl -L https://nixos.org/nix/install)
```

2. Pull Config
```
git clone https://github.com/firdausious/nixpkgs.git ~/.config/nixpkgs
cd ~/.config/nixpkgs
```

3. Build system
```
nix build .#homeConfigurations.aarch64-darwin.firdaus.activationPackage --extra-experimental-features nix-command --extra-experimental-features flakes
```

4. Activate
```
./result/activate
```



