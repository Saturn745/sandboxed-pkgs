{
  description = "A collection of packages that are sandboxed with Nixpak";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
      ];
      systems = ["x86_64-linux"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages = let
          mkNixPak = inputs.nixpak.lib.nixpak {
            inherit (pkgs) lib;
            inherit pkgs;
          };
          callNixPakPkg = file: args: let
            pkg = import file {
              inherit mkNixPak;
              inherit pkgs;
            };
          in
            pkg.config.env;
        in
          pkgs.lib.packagesFromDirectoryRecursive {
            callPackage = callNixPakPkg;
            directory = ./pkgs;
          };
      };
    };
}
