{
  hostName,
  pkgs,
  ...
}: {
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
  };
  networking = {
    inherit hostName;
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };
  security.rtkit.enable = true;
  virtualisation = {
    libvirtd.enable = true;
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
  };
  programs.virt-manager.enable = true;
  environment.systemPackages = with pkgs; [
    qemu
    dnsmasq
  ];
}
