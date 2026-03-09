{pkgs, ...}: {
  programs.opencode = {
    enable = true;
    package = pkgs.llm-agents.opencode;
    settings = {
      plugin = ["@mohak34/opencode-notifier@latest"];
    };
  };
  home.packages = with pkgs; [
    opencode-desktop
    llm-agents.ccusage-opencode
  ];
}
