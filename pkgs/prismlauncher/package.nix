{
  pkgs,
  mkNixPak,
}:
mkNixPak {
  config = {sloth, ...}: {
    app.package = pkgs.prismlauncher;
    flatpak.appId = "org.prismlauncher.PrismLauncher";

    imports = [
      ../../modules/network.nix
      ../../modules/gui-base.nix
    ];

    bubblewrap = {
      shareIpc = true;

      sockets = {
        wayland = true;
        x11 = true;
        pulse = true;
      };

      bind.rw = [
        "/tmp/.X11-unix"
        (sloth.concat' sloth.homeDir "/.local/share/PrismLauncher/") # Bind the PrismLauncher data directory
        (sloth.envOr "XAUTHORITY" "/no-xauth")
      ];

      bind.ro = [
        sloth.xdgDownloadDir # For mod drag and drop
        (sloth.concat' sloth.homeDir "/.ftba") # FTBApp importing

        # Some stuff required for certain JVM args
        "/sys/kernel/mm/hugepages"
        "/sys/kernel/mm/transparent_hugepage"
      ];

      bind.dev = [
        # For other input devices like game controllers. Similar to Flatpak --devices=all
        "/dev/input/"
      ];
    };
  };
}
