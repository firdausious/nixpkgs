# NixOS and Home-Manager Configuration

This repository contains a modular and reusable Nix configuration for managing my user environment with home-manager.

## 🏗️ Unified Configuration Architecture

This setup uses a **single folder/repo approach** that consolidates all Nix and Home Manager configurations without symlinks:

### ✅ **What's unified:**
- **All config files** in `/Users/firdaus/.config/nixpkgs/`:
  - `flake.nix` (Home Manager configuration)
  - `config.nix` (nixpkgs configuration) 
  - `nix.conf` (Nix tool configuration)
  - All your modules and custom configurations

### ✅ **How it works:**
1. **Explicit flake paths**: Home Manager commands use `--flake /path/to/your/nixpkgs` instead of relying on default locations
2. **Shell aliases**: Your `modules/shell.nix` provides convenient aliases:
   - `hm-switch` → `home-manager switch --flake ~/.config/nixpkgs#firdaus`
   - `hm-build` → `home-manager build --flake ~/.config/nixpkgs#firdaus`  
   - `hm-news` → `home-manager news --flake ~/.config/nixpkgs`
   - Plus all your existing `flakeup`, `nxb`, `nxa` aliases

### ✅ **Benefits:**
- **Single source of truth**: Everything in one versioned repository
- **No symlinks**: Clean, straightforward setup
- **No deprecation warnings**: Uses proper explicit paths
- **Manageable**: All configuration managed through your Nix modules

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

3. Enable experimental features (already configured in nix.conf)
```
# The nix.conf file in this repo automatically enables:
# experimental-features = nix-command flakes
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

### **Convenience Aliases (Built-in)**

This configuration automatically provides convenient aliases through the shell module (`modules/shell.nix`):

```bash
# Home Manager aliases (unified directory approach)
hm-switch          # Switch to new configuration
hm-build           # Build configuration without applying
hm-news            # Check Home Manager news

# Nix flake management
flakeup           # Update flake inputs
flake-show        # Show flake outputs
flake-check       # Check flake for errors

# Build and activate (legacy aliases)
nxb               # Build configuration
nxa               # Activate built configuration
```

After applying the configuration, you can simply run `hm-switch` to apply future changes without any setup needed.

---

# AI Development Assistant

This configuration includes a simple, language-agnostic AI assistant for code development using local LLMs via Ollama.

## AI Features

- **Language-Agnostic**: Works with Python, Javascript, Go, Rust, PHP, Java, C++, and more
- **Local LLMs**: Uses Ollama for privacy-focused local AI
- **Simple Commands**: Four simple commands: review, generate, analyze, chat
- **Git Integration**: Understands your project context
- **Minimal Setup**: Just one Python script (following LangChain requirement) and configuration
- **Cloud Optional**: Can use OpenAI/Anthropic if needed

## AI Setup

### Quick Start

1. **Apply Nix Configuration** (using any method above)

2. **Run AI Setup Script**:
   ```bash
   ~/.config/nixpkgs/scripts/setup-agentic-dev.sh
   ```

3. **Test the AI Assistant**:
   ```bash
   ai chat "hello world"
   ```

### Directory Structure

```
~/[workspace]/                # Configurable in modules/users/[username].nix
├── ai.py                     # Main AI assistant
├── bin/ai                    # Command wrapper
└── README.md                 # Usage guide

~/.config/[config-dir]/       # Configurable in user config
└── config.json               # Simple configuration
```

### Configuration

The AI workspace and configuration can be customized in `modules/users/[username].nix`:

```nix
aiConfig = {
  workspace = "dev-ai";              # Main AI workspace directory name
  configDir = ".config/dev-ai";      # Configuration directory  
  model = "llama3.1:8b";     # Default LLM model
  provider = "ollama";               # Default provider (ollama, openai, anthropic)
};
```

### Available Commands

```bash
# AI Assistant
ai review file.py         # Review code
ai generate "web server"  # Generate code  
ai analyze .              # Analyze project
ai chat "help me debug"   # General chat

# Ollama Management
llm-start                 # Start Ollama service
llm-stop                  # Stop Ollama service
llm-models               # List installed models
llm-chat model_name      # Chat with specific model
llm-test                 # Test connection

# Model Management
llm-pull model_name      # Download/add new models
llm-rm model_name        # Remove models
llm-show model_name      # Show model information

# Shortcuts
dev                      # Go to AI workspace
ai-workspace            # Go to AI workspace
ai-config               # Go to AI config directory
```

### Usage Examples

```bash
# Review any code file
ai review app.py
ai review main.go
ai review server.js

# Generate code in any language
ai generate "REST API with authentication" --language python
ai generate "React component for user profile" --language javascript
ai generate "HTTP server" --language go

# Analyze project structure
ai analyze ~/my-project
ai analyze .

# General development questions
ai chat "How do I optimize this SQL query?"
ai chat "Best practices for error handling in Go"
```

### Runtime Configuration

The AI assistant auto-creates a config file at `~/.config/[config-dir]/config.json`:

```json
{
  "model": "llama3.1:8b",
  "provider": "ollama", 
  "ollama_url": "http://127.0.0.1:11434",
  "temperature": 0.1
}
```

To use cloud providers, set API keys and update config:
```bash
export OPENAI_API_KEY="your-key"
export ANTHROPIC_API_KEY="your-key"
```

Then change the provider in config.json to "openai" or "anthropic".

### Supported Languages

The AI assistant automatically detects and works with:

- **Languanges**: Python, Go, Rust, PHP, Ruby, Java, C#, C, C++, Shell scripts, JavaScript, TypeScript, HTML, CSS
- **Config**: JSON, YAML, XML, SQL
- **Docs**: Markdown

Language detection is automatic based on file extensions.

### Troubleshooting

```bash
# Check if Ollama is running
llm-test

# Start Ollama if needed
llm-start

# List available models
llm-models

# Download model if missing
ollama pull llama3.1:8b

# Check installation status
~/[workspace]/check-install.sh
```

### Privacy & Security

- **Local by default**: Uses Ollama for completely local AI
- **No data sharing**: Your code never leaves your machine
- **Optional cloud**: Can use OpenAI/Anthropic if you prefer
- **Minimal dependencies**: Just LangChain and basic Python libraries

### Customization for Other Users

To adapt this setup for another user:

1. **Copy user configuration**:
   ```bash
   cp modules/users/firdaus.nix modules/users/[new-username].nix
   ```

2. **Update the aiConfig section** in the new file:
   ```nix
   aiConfig = {
     workspace = "my-ai-workspace";     # Your preferred directory name
     configDir = ".config/my-ai";      # Your preferred config directory
     model = "your-preferred-model";   # Your preferred default model
     provider = "your-provider";       # Your preferred provider
   };
   ```

3. **Add the new user** to `modules/defaults.nix`:
   ```nix
   defaultUsers = [ "firdaus" "new-username" ];
   ```

4. **Apply the configuration**:
   ```bash
   nix --extra-experimental-features "nix-command flakes" run .#homeConfigurations.[new-username].activationPackage
   ```
