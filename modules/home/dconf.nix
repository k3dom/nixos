{pkgs, ...}: {
  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        favorite-apps = [];
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          paperwm.extensionUuid
          tailscale-qs.extensionUuid
        ];
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        show-battery-percentage = true;
        icon-theme = "MoreWaita";
      };
      "org/gnome/desktop/input-sources".xkb-options = [
        "terminate:ctrl_alt_bksp"
        "caps:swapescape"
      ];
      "org/gnome/mutter" = {
        workspaces-only-on-primary = false;
        dynamic-workspaces = false;
      };
      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 4;
        focus-mode = "sloppy";
      };
      "org/gnome/desktop/notifications".banner-timeout = 3;
      "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";
      "org/gnome/shell/extensions/paperwm/keybindings" = {
        switch-next = ["<Super>k"];
        switch-previous = ["<Super>j"];
        move-right = ["<Super><Ctrl>k" "<Super><Shift>k" "<Super><Ctrl>Right"];
        move-left = ["<Super><Ctrl>j" "<Super><Shift>j" "<Super><Ctrl>Left"];
        center-vertically = [];
      };
      "org/gnome/shell/extensions/paperwm" = {
        show-workspace-indicator = false;
        show-focus-mode-icon = false;
        default-focus-mode = 2; # edge
        show-open-position-icon = false;
        open-window-position = 0;
        open-window-position-option-right = false;
        open-window-position-option-left = false;
        open-window-position-option-down = false;
        open-window-position-option-up = false;
      };
    };
  };
}
