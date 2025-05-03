{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, lib, ... }:
        let
          god = pkgs.stdenv.mkDerivation {
            name = "god";
            src = lib.cleanSource ./.;

            nativeBuildInputs = [
              pkgs.scons
            ];

            buildPhase = ''
              scons
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp .build/god $out/bin
            '';
          };
        in
        {
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };

          packages = {
            inherit god;
            default = god;
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.nil
              pkgs.ruff
              pkgs.scons
            ];
          };
        };
    };
}
