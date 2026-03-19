{
  homeStateVersion,
  user,
  ...
}: {
  imports = [
    ../home
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = homeStateVersion;
    sessionVariables = {
      EDITOR = "nvim";
      ANDROID_HOME = "$HOME/Android/Sdk";
    };
    sessionPath = [
      "$HOME/Android/Sdk/emulator"
      "$HOME/Android/Sdk/platform-tools"
    ];
  };
}
