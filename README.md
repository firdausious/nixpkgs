# NixOS and Home-Manager Configuration

This repository contains a modular and reusable Nix configuration for managing my user environment with home-manager.

## Quick Start

1. Install Nix
```
sh <(curl -L https://nixos.org/nix/install)
```

2. Pull Config
```
# Clone your forked repository
git clone https://github.com/firdausious/nixpkgs.git ~/.config/nixpkgs
cd ~/.config/nixpkgs
```

## ✅ Complete Build & Usage Guide

### **Building & Testing**

Before applying any changes, it's a good practice to build and check the configuration to catch any errors.

1.  **Build/test the configuration:**

    ```bash
    nix --extra-experimental-features nix-command --extra-experimental-features flakes build .#homeConfigurations.firdaus.activationPackage
    ```

2.  **Check for errors:**

    ```bash
    nix --extra-experimental-features nix-command --extra-experimental-features flakes flake check
    ```

### **Applying the Configuration**

Once you've verified the configuration, you can apply it using one of these methods:

**Method 1: Build and Activate (Recommended)**

3a. **Build the configuration:**

    ```bash
    nix --extra-experimental-features "nix-command flakes" build .#homeConfigurations.firdaus.activationPackage
    ```

3b. **Activate the built configuration:**

    ```bash
    ./result/activate
    ```

**Method 2: Direct Run**

3.  **Apply the configuration directly (activates it):**

    ```bash
    nix --extra-experimental-features nix-command --extra-experimental-features flakes run .#homeConfigurations.firdaus.activationPackage
    ```

### **Alternative Method (using home-manager CLI)**

If you have `home-manager` installed as a standalone tool, you can also use its CLI to switch to the new configuration.

```bash
home-manager switch --flake .#firdaus
```

### **Making Changes**

When you want to modify your configuration:

1.  Edit files in the `modules/` directory or add new user configurations.
2.  Build to test your changes: `nix --extra-experimental-features "nix-command flakes" build .#homeConfigurations.firdaus.activationPackage`
3.  Apply the new configuration: `./result/activate`

### **Convenience Alias**

To make applying changes easier, you can add this alias to your shell profile (e.g., `.zshrc` or `.bashrc`):

```bash
alias hm-switch="nix --extra-experimental-features nix-command --extra-experimental-features flakes run ~/.config/nixpkgs#homeConfigurations.firdaus.activationPackage"
```

After adding the alias and restarting your shell, you can simply run `hm-switch` to apply your changes.
