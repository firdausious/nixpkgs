{ pkgs, pkgs-unstable, lib, homeDirectory, aiConfig, basePythonPackages }:

let
  # AI-specific Python packages extending the base backend packages
  aiPythonPackages = ps: (basePythonPackages ps) ++ (with ps; [
    # AI/ML specific packages
    langchain
    langchain-core
    langchain-community
    langchain-ollama
    langchain-openai
    langchain-anthropic
    
    # Vector databases and embeddings (optional - commented out for minimal setup)
    # chromadb
    # faiss
    # sentence-transformers
    # transformers
    # torch
    
    # Additional ML libraries if needed
    # scikit-learn
    # matplotlib
    # seaborn
    # plotly
    # jupyter
    # ipython
  ]);

  # Python environment with AI extensions
  pythonWithAI = pkgs.python313.withPackages aiPythonPackages;

in {
  # AI/ML packages - minimal and language agnostic
  aiPackages = with pkgs; [
    # Core AI tools
    ollama                    # Local LLM server
    
    # Universal code analysis
    tree-sitter              # Language parsing
    ast-grep                 # Multi-language AST search
    
    # API tools
    curl                     # HTTP requests
    jq                       # JSON processing
  ];

  # Python environment with AI extensions (to replace base Python)
  pythonWithAIExtensions = pythonWithAI;

  # Environment variables for AI development
  aiSessionVariables = {
    # Ollama configuration
    OLLAMA_HOST = "127.0.0.1:11434";
    
    # Development paths (using centralized config)
    AI_WORKSPACE_DIR = "${homeDirectory}/${aiConfig.workspace}";
    AI_CONFIG_PATH = "${homeDirectory}/${aiConfig.configDir}";
  };

  # Simple aliases for AI development (using centralized config)
  aiAliases = {
    # Core AI tools
    "ai" = "cd $AI_WORKSPACE && python ai.py";
    "ai-setup" = "$AI_WORKSPACE/setup.sh";
    
    # Ollama management
    "llm-start" = "ollama serve";
    "llm-stop" = "pkill -f 'ollama serve'";
    "llm-models" = "ollama list";
    "llm-chat" = "ollama run";
    
    # Model management
    "llm-pull" = "ollama pull";
    "llm-rm" = "ollama rm";
    "llm-show" = "ollama show";
    
    # Code analysis (language agnostic)
    "analyze" = "cd $AI_WORKSPACE && python ai.py analyze";
    "review" = "cd $AI_WORKSPACE && python ai.py review";
    "generate" = "cd $AI_WORKSPACE && python ai.py generate";
    
    # Test LLM connection
    "llm-test" = "curl -s http://127.0.0.1:11434/api/tags | jq .";
  };

  # Session paths for AI tools (using centralized config)
  aiSessionPath = [
    "${homeDirectory}/${aiConfig.workspace}/bin"
  ];
}
