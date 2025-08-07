# User-specific configuration for firdaus
{ pkgs, lib, ... }:

let
  # AI Development Configuration - centralized for easy customization
  aiConfig = {
    workspace = "dev-ai";              # Main AI workspace directory name
    configDir = ".config/dev-ai";      # Configuration directory
    model = "deepseek-coder:6.7b";     # Default LLM model
    provider = "ollama";               # Default provider (ollama, openai, anthropic)
  };
in
{
  # User-specific packages (optional)
  extraPackages = with pkgs; [
    # Add any user-specific packages here
  ];
  
  # User-specific aliases (optional)
  extraAliases = {
    # Development shortcuts
    "dev" = "cd ~/${aiConfig.workspace}";
    
    # AI-specific shortcuts
    "ai-workspace" = "cd ~/${aiConfig.workspace}";
    "ai-config" = "cd ~/${aiConfig.configDir}";
  };
  
  # User-specific environment variables (optional)
  extraSessionVariables = {
    # Development editor
    EDITOR = "nvim";
    
    # AI workspace configuration - centralized
    AI_WORKSPACE = "$HOME/${aiConfig.workspace}";
    AI_CONFIG_DIR = "$HOME/${aiConfig.configDir}";
    AI_MODEL = aiConfig.model;
    AI_PROVIDER = aiConfig.provider;
    
    # Python optimization
    PYTHONUNBUFFERED = "1";
    PYTHONDONTWRITEBYTECODE = "1";
  };
  
  # Export AI configuration for use by other modules
  inherit aiConfig;
}
