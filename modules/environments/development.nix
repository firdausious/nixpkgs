{ pkgs, ... }:

{
  # Development-specific packages
  packages = with pkgs; [
    # CI/CD tools
    act
    
    # Container tools
    docker-compose
    
    # Database tools
    postgresql
    redis
    
    # Testing tools
    k6
    
    # Additional dev tools
    direnv
    just
  ];
  
  # Development environment variables
  sessionVariables = {
    # Enable direnv
    DIRENV_LOG_FORMAT = "";
  };
}
