{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
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
            pname = "god";
            version = "dev";
            src = lib.cleanSource ./.;

            nativeBuildInputs = [
              pkgs.zig_0_13.hook
            ];
          };
        in
        {
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.zig.enable = true;
          };

          packages = {
            inherit god;
            default = god;
          };

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.zig_0_13
              pkgs.nil
            ];
          };
        };
    };
}
