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
    vite-plus
    mitmproxy
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
    inputs.nvim.packages.${system}.default
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
    zoom-us
    teams-for-linux
    # gnome
    morewaita-icon-theme
    gnomeExtensions.paperwm
    gnomeExtensions.tailscale-qs
  ];

  # packages with home-manager modules
  programs = {
    home-manager.enable = true;
    # packages
    fastfetch.enable = true;
    lazygit.enable = true;
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
    calibre.enable = true;
  };
}
