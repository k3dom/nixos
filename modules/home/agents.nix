{pkgs, ...}: {
  programs = {
    opencode = {
      enable = true;
      package = pkgs.llm-agents.opencode;
      settings = {
        share = "disabled";
        autoupdate = false;
        lsp = false;
        plugin = [
          # https://github.com/mohak34/opencode-notifier
          "@mohak34/opencode-notifier@0.2.3"
          # https://github.com/griffinmartin/opencode-claude-auth
          "opencode-claude-auth@1.5.0"
        ];
      };
    };
    claude-code = {
      enable = true;
      package = pkgs.llm-agents.claude-code.override {
        disableTelemetry = true;
      };
    };
  };
  xdg.configFile."opencode/opencode-notifier.json".text = builtins.toJSON {
    sound = true;
    notification = false;
  };
  home.packages = with pkgs; [
    opencode-desktop
    llm-agents.pi
    llm-agents.ccusage
    llm-agents.ccusage-opencode
  ];
}
