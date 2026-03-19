{
  pkgs,
  user,
  ...
}: {
  programs = {
    # For vendor completions we need to enable the fish shell
    # here ontop of enabling it in home-manager.
    fish.enable = true;
    # GPG support via home-manager currently has some issues
    # Mainly issues with pinentry not working properly aswell as
    # the default settings not being optimal.
    # https://github.com/nix-community/home-manager/issues/5383
    # https://github.com/nix-community/home-manager/issues/5146
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
  users = {
    defaultUserShell = pkgs.fish;
    users.${user} = {
      isNormalUser = true;
      description = user;
      extraGroups = [
        "networkmanager"
        "wheel"
        "kvm"
        "docker"
      ];
    };
  };
}
