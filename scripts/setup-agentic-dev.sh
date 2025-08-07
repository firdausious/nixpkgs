#!/usr/bin/env bash

# Simple AI Development Setup
# Language-agnostic AI assistant setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration - using environment variables from Nix config
AI_WORKSPACE="${AI_WORKSPACE:-$HOME/dev-ai}"  # Fallback if env var not set
CONFIG_DIR="${AI_CONFIG_DIR:-$HOME/.config/dev-ai}"  # Fallback if env var not set
AI_MODEL="${AI_MODEL:-deepseek-coder:6.7b}"  # Default model
AI_PROVIDER="${AI_PROVIDER:-ollama}"  # Default provider

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create directory structure
setup_directories() {
    print_step "Creating directory structure..."
    
    directories=(
        "$AI_WORKSPACE"
        "$AI_WORKSPACE/bin"
        "$CONFIG_DIR"
    )
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            echo "Created: $dir"
        fi
    done
    
    print_success "Directory structure created"
}

# Copy configuration files
setup_config() {
    print_step "Setting up AI assistant..."
    
    # Copy AI script
    if [[ ! -f "$AI_WORKSPACE/ai.py" ]]; then
        if [[ -f "$HOME/.config/nixpkgs/templates/ai.py" ]]; then
            cp "$HOME/.config/nixpkgs/templates/ai.py" "$AI_WORKSPACE/ai.py"
            chmod +x "$AI_WORKSPACE/ai.py"
            print_success "AI assistant copied to $AI_WORKSPACE"
        else
            print_warning "AI template not found"
        fi
    else
        print_success "AI assistant already exists"
    fi
    
    # Create simple wrapper script
    cat > "$AI_WORKSPACE/bin/ai" << EOF
#!/bin/bash
cd "$AI_WORKSPACE" && python ai.py "\$@"
EOF
    chmod +x "$AI_WORKSPACE/bin/ai"
    print_success "AI wrapper script created"
}

# Setup Ollama and download models
setup_ollama() {
    print_step "Setting up Ollama and downloading models..."
    
    if ! command_exists ollama; then
        print_error "Ollama not found. Please ensure your Nix configuration is applied first."
        return 1
    fi
    
    # Check if Ollama service is running
    if ! pgrep -f "ollama serve" >/dev/null; then
        print_step "Starting Ollama service..."
        ollama serve &
        OLLAMA_PID=$!
        echo $OLLAMA_PID > "$CACHE_DIR/ollama.pid"
        
        # Wait for Ollama to start
        sleep 5
        
        if ! pgrep -f "ollama serve" >/dev/null; then
            print_error "Failed to start Ollama service"
            return 1
        fi
        
        print_success "Ollama service started"
    else
        print_success "Ollama service is already running"
    fi
    
    # Download essential model
    model="deepseek-coder:6.7b"
    
    print_step "Downloading model: $model"
    if ollama list | grep -q "${model%:*}"; then
        print_success "Model $model already exists"
    else
        ollama pull "$model" || {
            print_warning "Failed to download $model"
            print_step "You can download it later with: ollama pull $model"
        }
    fi
}



# Create usage examples
create_examples() {
    print_step "Creating usage examples..."
    
    cat > "$AI_WORKSPACE/README.md" << 'EOF'
# Simple AI Development Assistant

Language-agnostic AI assistant for code development.

## Usage

```bash
# Review code
ai review path/to/file.py

# Generate code
ai generate "create a REST API endpoint" --language python

# Analyze project
ai analyze path/to/project

# Chat with AI
ai chat "how to optimize this algorithm"
```

## Configuration

Edit `~/.config/dev-ai/config.json` to customize:

```json
{
  "model": "deepseek-coder:6.7b",
  "provider": "ollama",
  "ollama_url": "http://127.0.0.1:11434",
  "temperature": 0.1
}
```

## Supported Languages

- Python, JavaScript, TypeScript
- Go, Rust, PHP, Ruby, Java
- C, C++, C#, Shell
- SQL, HTML, CSS, JSON, YAML
- Markdown, XML
EOF

    print_success "Examples and documentation created"
}

# Print final instructions
print_final_instructions() {
    print_success "Simple AI Development Setup Complete!"
    
    echo ""
    echo -e "${BLUE}Directory Structure:${NC}"
    echo "  AI Workspace: $AI_WORKSPACE"
    echo "  Configuration: $CONFIG_DIR"
    
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Rebuild your Nix configuration:"
    echo "   home-manager switch --flake ~/.config/nixpkgs/#firdaus"
    
    echo ""
    echo "2. Test the AI assistant:"
    echo "   ai chat 'hello world'"
    
    echo ""
    echo "3. Try other commands:"
    echo "   ai review some_file.py     # Review code"
    echo "   ai generate 'web server'   # Generate code"
    echo "   ai analyze .              # Analyze project"
    
    echo ""
    echo "4. Ollama management:"
    echo "   llm-start                 # Start Ollama"
    echo "   llm-models               # List models"
    echo "   llm-test                 # Test connection"
    
    echo ""
    echo -e "${YELLOW}Note:${NC} Configuration file will be auto-created at:"
    echo "  $CONFIG_DIR/config.json"
}

# Main execution
main() {
    echo -e "${GREEN}Simple AI Development Setup${NC}"
    echo "================================"
    
    setup_directories
    setup_config
    setup_ollama
    create_examples
    print_final_instructions
}

# Run main function
main "$@"
