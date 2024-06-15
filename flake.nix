{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";
    zig.url = "github:mitchellh/zig-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, nixpkgs, systems, flake-utils, zig, treefmt-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays =
          [ (final: prev: { zigpkgs = zig.packages.${prev.system}; }) ];
        pkgs = import nixpkgs { inherit system overlays; };
        eachSystem = f:
          pkgs.lib.genAttrs (import systems)
          (systems: f nixpkgs.legacyPackages.${system});
        treefmtEval =
          eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
      in {
        # Use `nix fmt`
        formatter = treefmtEval.${system}.config.build.wrapper;

        # Use `nix flake check`
        checks.formatting = treefmtEval.${system}.config.build.check self;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ zigpkgs."0.13.0" ];

          shellHook = ''
            export PS1="\n[nix-shell:\w]$ "
          '';
        };
      });
}

