{
  pkgs,
  user,
  hostName,
  ...
}: let
  signKeys = {
    desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKu4aqjfTRLu3DTl/YzgObwinrPKKFx9/yPNWvaAFEWv kedom@desktop";
    t480 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINclt0A84Dn613MpK68mxlpaK6q3uLhB/SFKidaygRta kedom@t480";
  };
  signKey =
    if builtins.hasAttr hostName signKeys
    then signKeys.${hostName}
    else throw "No SSH signing key for hostname: ${hostName}";
in {
  home = {
    file.".ssh/allowed_signers".text = ''
      * ${signKey}
    '';
    packages = with pkgs; [
      git-wt
    ];
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing = {
      format = "ssh";
      key = signKey;
      signByDefault = true;
    };
    maintenance = {
      enable = true;
      repositories = let
        gitDir = "/home/${user}/Public/Git/";
      in [
        (gitDir + "progono/mono")
        (gitDir + "nvim")
        (gitDir + "nixbox")
      ];
    };
    includes = [
      {
        condition = "gitdir:/home/${user}/Public/Git/progono/mono/";
        contents.wt = {
          basedir = ".git/wt";
          hook = "pnpm i";
          copy = [".env" ".env*.local"];
        };
      }
    ];
    settings = {
      user = {
        name = "kedom";
        email = "kedom@vmcall.net";
      };
      pull.ff = "only";
      diff.tool = "meld";
      merge.tool = "meld";
      column.ui = "auto";
      branch.sort = "-committerdate";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };
}
