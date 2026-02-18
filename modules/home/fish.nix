{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        fish_vi_key_bindings

        bind -M insert \cf accept-autosuggestion
        bind -M insert \cr history-pager

        abbr -a k   "kubectl"
        abbr -a kn  "kubens"
        abbr -a kc  "kubectx"
        abbr -a oc  "opencode"
        abbr -a g   "git"
      '';
    };
    # Disable slow generation of man caches that fish enables automatically
    # via the `documentation.man.generateCaches` option.
    man.generateCaches = false;
  };
}
