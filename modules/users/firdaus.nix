# User-specific configuration for firdaus
{ pkgs, lib, ... }:

{
  # User-specific packages (optional)
  extraPackages = with pkgs; [
    # Add any user-specific packages here
  ];
  
  # User-specific aliases (optional)
  extraAliases = {
    # Add user-specific aliases here
  };
  
  # User-specific environment variables (optional)
  extraSessionVariables = {
    # Add user-specific env vars here
  };
}
