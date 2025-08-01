{ pkgs, homeDirectory }:

{
  # Go configuration
  go = {
    enable = true;
    package = pkgs.go;
    goPath = "${homeDirectory}/go";
    goBin = "${homeDirectory}/go/bin/";
  };

  # Environment variables for different languages
  sessionVariables = {
    ANDROID_HOME = "$HOME/Library/Android/sdk";
  };

  sessionPath = [
    "$ANDROID_HOME/emulator"
    "$ANDROID_HOME/cmdline-tools/latest/bin"
    "$ANDROID_HOME/platform-tools"
    "$ANDROID_HOME/build-tools/30.0.3"
  ];
}
