{
  inputs,
  pkgs,
  system,
  ...
}: {
  # Packages without a home-manager module
  home.packages = with pkgs; [
    # General packages
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
    mitmproxy
    tokei
    texliveFull
    postgresql
    libnotify
    inetutils
    dnsutils
    openssl
    kubectl
    kubernetes-helm
    kind
    kubectx
    python3
    morewaita-icon-theme
    gnomeExtensions.paperwm
    gnomeExtensions.tailscale-qs
    inputs.nvim.packages.${system}.default
    # Desktop applications
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
    meld
    drawing
    zoom-us
    teams-for-linux
    android-studio
  ];
  # Packages with home-manager modules
  programs = {
    # General packages
    home-manager.enable = true;
    fastfetch.enable = true;
    lazygit.enable = true;
    fzf.enable = true;
    zoxide.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    gh.enable = true;
    jq.enable = true;
    k9s.enable = true;
    # Desktop applications
    firefox.enable = true;
    obsidian.enable = true;
    vscode.enable = true;
    discord.enable = true;
    calibre.enable = true;
  };
}
