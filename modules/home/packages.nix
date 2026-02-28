{
  inputs,
  pkgs,
  system,
  ...
}: {
  home.packages = with pkgs; [
    # packages
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_DE
    lm_sensors
    unzip
    p7zip
    yq
    sqlite
    lsof
    ffmpeg
    imagemagick
    pnpm
    nodejs
    # mitmproxy
    tokei
    texliveFull
    postgresql
    inetutils
    dnsutils
    openssl
    kubectl
    kubernetes-helm
    kind
    kubectx
    python3
    git-wt
    # desktop apps
    gtranslator
    pavucontrol
    bitwarden-desktop
    _1password-gui
    vlc
    qbittorrent
    spotify
    libreoffice-fresh
    darktable
    yaak
    projectlibre
    meld
    drawing
    # gnome
    morewaita-icon-theme
    gnomeExtensions.paperwm
    gnomeExtensions.tailscale-qs
    # inputs
    inputs.nvim.packages.${system}.default
    inputs.llm-agents.packages.${system}.opencode
  ];

  # packages with home-manager modules
  programs = {
    home-manager.enable = true;
    # packages
    fastfetch.enable = true;
    lazygit.enable = true;
    eza.enable = true;
    fzf.enable = true;
    zoxide.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    gh.enable = true;
    jq.enable = true;
    k9s.enable = true;
    # desktop apps
    firefox.enable = true;
    obsidian.enable = true;
    vscode.enable = true;
    discord.enable = true;
    # calibre.enable = true;
  };
}
