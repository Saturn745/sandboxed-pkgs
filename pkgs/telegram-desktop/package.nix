{
  pkgs,
  mkNixPak,
  ...
}:
mkNixPak {
  config = {sloth, ...}: {
    app.package = pkgs.telegram-desktop;
    flatpak.appId = "org.telegram.desktop";
    imports = [
      ../../modules/network.nix # Updated path for network module
      ../../modules/gui-base.nix # Updated path for GUI-related configurations
    ];

    # Enable D-Bus and set policies
    dbus.enable = true;

    dbus.policies = {
      "org.gnome.Mutter.IdleMonitor" = "talk"; # GNOME Idle Monitor
      "org.kde.StatusNotifierWatcher" = "talk"; # KDE tray functionality
      "com.canonical.AppMenu.Registrar" = "talk"; # Canonical app menu
      "com.canonical.indicator.application" = "talk"; # Canonical application indicators
      "org.ayatana.indicator.application" = "talk"; # Ayatana application indicators
    };

    bubblewrap = {
      bind.rw = [
        (sloth.concat' sloth.homeDir "/.local/share/TelegramDesktop/") # Bind the PrismLauncher data directory
        sloth.xdgDownloadDir # Telegram automatically saves downloaded files to "Downloads/Telegram Downloads"
        (sloth.concat' (sloth.env "XDG_RUNTIME_DIR") "/pipewire-0") # Pipewire interfacing
      ];
      bind.dev = [
        "/dev/dri" # GPU access
      ];
    };
  };
}
