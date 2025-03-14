{
  description = "bsky - A CLI client for Bluesky social network";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          default = bsky;

          bsky = pkgs.buildGoModule {
            pname = "bsky";
            version = "0.0.73"; # Version from main.go

            src = ./.;

            vendorHash = "sha256-mJUjxcBl4WFszknoudBvqFk6LE7tGHkD26kRmkPUYTI=";

            # Don't use vendor directory
            proxyVendor = true;

            ldflags = [
              "-s"
              "-w"
              "-X"
              "main.revision=${self.shortRev or "dirty"}"
            ];

            meta = with pkgs.lib; {
              description = "A CLI client for Bluesky social network";
              homepage = "https://github.com/mattn/bsky";
              license = licenses.mit;
              mainProgram = "bsky";
            };
          };
        };

        apps = rec {
          default = bsky;
          bsky = flake-utils.lib.mkApp { drv = self.packages.${system}.bsky; };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            go-tools
          ];
        };
      }
    );
}
