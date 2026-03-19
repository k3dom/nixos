{
  config,
  lib,
  pkgs,
  user,
  ...
}: let
  cfg = config.modules.system.libvirt;
in {
  options.modules.system.libvirt = {
    enable = lib.mkEnableOption "Enable libvirt, QEMU, and virt-manager support";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    environment.systemPackages = with pkgs; [
      qemu
      dnsmasq
    ];
    users.users.${user}.extraGroups = [
      "libvirtd"
    ];
  };
}
