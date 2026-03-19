{stateVersion, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  system.stateVersion = stateVersion;

  boot.initrd.luks.devices."luks-d694e8dd-2cfc-4da7-8558-e295ecd18d21".device = "/dev/disk/by-uuid/d694e8dd-2cfc-4da7-8558-e295ecd18d21";

  modules.system.libvirt.enable = true;
  modules.system.nvidia.enable = true;
  services.goxlr-utility = {
    enable = true;
    autoStart.xdg = true;
  };
}
