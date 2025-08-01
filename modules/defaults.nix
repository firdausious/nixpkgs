# Default configuration values that can be overridden
{ releaseVersion }:
{
  # Default Home Manager state version (update this when needed)
  stateVersion = releaseVersion;
  
  # Default system configuration
  allowUnfree = true;
  
  # Default Nix configuration directory
  nixConfigDirectory = "~/.config/nixpkgs";
  
  # Default users (can be overridden)
  defaultUsers = [ "firdaus" ];
}
