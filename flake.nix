{
  description = "A customizable tool for theming linux systems";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
      treefmt-nix,
    }:
    let

      eachDefaultEnvironment =
        f:
        flake-utils.lib.eachDefaultSystem (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                self.overlays.default
                (import rust-overlay)
              ];
            };
          }
        );
      pkgsFor = nixpkgs.legacyPackages;
    in
    eachDefaultEnvironment (
      { system, pkgs }: {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.rustc
            pkgs.cargo
            pkgs.gcc
            pkgs.just
            pkgs.rust-analyzer
            pkgs.lua-language-server
            pkgs.nil
            pkgs.efm-langserver
            pkgs.prettierd
            pkgs.marksman
            pkgs.pkg-config
            pkgs.luajit
            pkgs.mdbook
            pkgs.nixfmt
            pkgs.statix
          ];
        };

        packages.default = pkgsFor.${system}.callPackage ./. { };

        homeModules = import ./home-module.nix;

        formatter = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper;

        checks.formatting = (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.check self;
      }
    )
    // {
      overlays.default = import ./overlay.nix;
    };
}
