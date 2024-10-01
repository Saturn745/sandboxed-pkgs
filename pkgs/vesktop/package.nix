{
  pkgs,
  mkNixPak,
  ...
}:
# Slightly bugged right now. The xdg-desktop-portal file picker doesn't work. Not sure why
mkNixPak {
  config = {sloth, ...}: {
    app.package = pkgs.vesktop; # Replace with the actual app package
    flatpak.appId = "dev.vencord.Vesktop"; # Replace with your app ID

    imports = [
      ../../modules/network.nix
      ../../modules/gui-base.nix
    ];

    # Enable D-Bus and set policies
    dbus.enable = true;

    dbus.policies = {
      "org.kde.StatusNotifierWatcher" = "talk"; # Tray functionalities on KDE
    };

    bubblewrap = {
      shareIpc = true;
      sockets = {
        wayland = true; # Enable Wayland socket
        x11 = true; # Enable X11 socket
        pulse = true; # Enable Pulseaudio socket
      };
      bind.ro = [
        sloth.xdgVideosDir # Read-only access to Videos
        sloth.xdgPicturesDir # Read-only access to Pictures
        "/run/dbus/system_bus_socket" # Not entirely sure why if needed but it was warning in terminal that it couldn't be found
      ];
      bind.rw = [
        (sloth.concat' (sloth.env "XDG_RUNTIME_DIR") "/pipewire-0") # Pipewire interfacing
        (sloth.concat' (sloth.env "XDG_RUNTIME_DIR") "/speech-dispatcher") # For TTS and VcNarrator
        (sloth.concat' sloth.homeDir "/.steam") # Needed for SteamOS integration
        sloth.xdgDownloadDir # For drag-and-drop and download management
        (sloth.concat' sloth.xdgConfigHome "/vesktop") # Vesktop configuration/data directory
      ];
      bind.dev = [
        "/dev/dri" # Device access for GPU
        "/dev/video0" # Webcam access | TODO: Find a way to get all video devices
      ];
    };
  };
}
