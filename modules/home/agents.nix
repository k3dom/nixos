{pkgs, ...}: {
  programs = {
    opencode = {
      enable = true;
      package = pkgs.llm-agents.opencode;
      settings = {
        plugin = [
          "@mohak34/opencode-notifier@latest"
          "opencode-claude-auth"
        ];
      };
    };
    claude-code = {
      enable = true;
      package = pkgs.llm-agents.claude-code;
    };
  };
  home.packages = with pkgs; [
    opencode-desktop
    llm-agents.ccusage
    llm-agents.ccusage-opencode
  ];
}
