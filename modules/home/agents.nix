{pkgs, ...}: {
  programs = {
    opencode = {
      enable = true;
      package = pkgs.llm-agents.opencode;
      settings = {
        plugin = [
          # https://github.com/mohak34/opencode-notifier
          "@mohak34/opencode-notifier@0.2.2"
          # https://github.com/griffinmartin/opencode-claude-auth
          "opencode-claude-auth@1.5.0"
        ];
      };
    };
    claude-code = {
      enable = true;
      package = pkgs.llm-agents.claude-code;
    };
  };
  xdg.configFile."opencode/opencode-notifier.json".text = builtins.toJSON {
    sound = true;
    notification = false;
  };
  home.packages = with pkgs; [
    opencode-desktop
    llm-agents.ccusage
    llm-agents.ccusage-opencode
  ];
}
