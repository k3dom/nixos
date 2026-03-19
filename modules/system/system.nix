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
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
}
