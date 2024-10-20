{
  description = "Home manager configuration";

  inputs = {
    nixpkgs.url = "github:miuirussia/nixpkgs?ref=nixpkgs-unstable";
    nixpkgs-hls.url = "github:nixos/nixpkgs?ref=91065f31dd63e99541528b90daed641201099ea7";

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zsh plugins
    base16-shell = {
      url = "github:chriskempson/base16-shell";
      flake = false;
    };
    zsh-syntax-highlighting = {
      url = "github:zsh-users/zsh-syntax-highlighting";
      flake = false;
    };
    fast-syntax-highlighting = {
      url = "github:zdharma-continuum/fast-syntax-highlighting";
      flake = false;
    };
    zsh-history-substring-search = {
      url = "github:zsh-users/zsh-history-substring-search";
      flake = false;
    };
    zsh-nix-shell = {
      url = "github:chisui/zsh-nix-shell";
      flake = false;
    };
    zsh-yarn-completions = {
      url = "github:chrisands/zsh-yarn-completions";
      flake = false;
    };

    # flake utils
    systems.url = "github:nix-systems/default-linux";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      systems,
      home-manager,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs (import systems);

      composeExtensions =
        f: g: final: prev:
        let
          fApplied = f final prev;
          prev' = prev // fApplied;
        in
        fApplied // g final prev';

      nixpkgsOverlays =
        let
          path = ./overlays;
        in
        with builtins;
        map (n: (import (path + ("/" + n)) inputs)) (
          filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
            attrNames (readDir path)
          )
        );

      overlays = nixpkgsOverlays ++ [
        inputs.fenix.overlays.default
        (final: prev: {
          yandex-browser-beta = inputs.yandex-browser.packages.${prev.system}.yandex-browser-beta;
          yandex-browser-stable = inputs.yandex-browser.packages.${prev.system}.yandex-browser-stable;
        })
      ];

      nixpkgsConfig = {
        config = {
          allowUnfree = true;
        };
        inherit overlays;
      };

      pkgs = system: import nixpkgs {
        inherit system;
        inherit (nixpkgsConfig) config overlays;
      };
    in
    {
      formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      
      homeConfigurations.kirill = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs "x86_64-linux";

        extraSpecialArgs = {
          inherit inputs;
        };

        modules = [
          {
            home.username = "kirill";
            home.homeDirectory = "/home/kirill";
            nixGLPrefix = "${inputs.nixgl.packages.x86_64-linux.nixGLDefault}/bin/nixGL";
            nixpkgs = {
              inherit (nixpkgsConfig) config overlays;
            };
          }
          ./modules/nixGL.nix

          ./home.nix
        ];
      };

      apps = eachSystem (system:

      let
        packages = pkgs system;
        nix = "${packages.nixVersions.git}/bin/nix --extra-experimental-features 'nix-command flakes'";
      in {
        update = with nixpkgs.legacyPackages.${system}; {
          type = "app";
          program = "${
            (writeShellScript "update" ''
              set -euo pipefail
              echo "Update nix flakes..."
              ${nix} flake update
              echo "Update vscode plugins..."
              (cd overlays/vscode && ./update-vscode-plugins.py)
              (cd overlays/vscode/codelldb && ./update.sh)
              echo "Update node modules..."
              (cd overlays/nodePackages/lib && ${node2nix}/bin/node2nix -i node-packages.json -18)
            '')
          }";
        };

        switch = with nixpkgs.legacyPackages.${system}; {
          type = "app";
          program = "${
            (writeShellScript "switch" ''
              set -euo pipefail
              export PATH=${
                lib.makeBinPath [
                  coreutils
                  gitMinimal
                  hostname
                  jq
                ]
              }
              export NIXPKGS_ALLOW_INSECURE=1
              configName="$USER"

              1>&2 echo "Switching Home Manager configuration for: $configName"

              exists="$(${nix} eval --json .#homeConfigurations --apply 'x: (builtins.any (n: n == "'$configName'") (builtins.attrNames x))' 2>/dev/null)"

              if [ "$exists" != "true" ]; then
                1>&2 echo "No configuration found, aborting..."
                exit 1
              fi

              1>&2 echo "Building configuration..."
              emptyPath="$(mktemp -d)"
              out="$(NIX_PATH="nixpkgs-overlays=$emptyPath" ${nix} build $@ --no-link --impure --json "${self}#homeConfigurations.$configName.activationPackage" | jq -r .[].outputs.out)"
              rm -rf "$emptyPath"
              1>&2 echo "Activating configuration $out..."
              "$out"/activate
            '')
          }";
        };

        cache = with nixpkgs.legacyPackages.${system}; {
          type = "app";
          program = "${
            (writeShellScript "cache" ''
              set -euo pipefail
              export PATH=${
                lib.makeBinPath [
                  coreutils
                  gitMinimal
                  hostname
                  jq
                  cachix
                ]
              }

              export NIXPKGS_ALLOW_INSECURE=1
              emptyPath="$(mktemp -d)"
              ${nix} eval --json .#homeConfigurations --apply 'x: (builtins.attrNames x)' 2>/dev/null | jq -c -r '.[]' | while read name; do
                echo "Caching configuration $name..."
                NIX_PATH="nixpkgs-overlays=$emptyPath" ${nix} build $@ --no-link --impure --json "${self}#homeConfigurations.$name.activationPackage" | jq -r '.[].outputs | to_entries[].value' | cachix push kdevlab
              done
              rm -rf "$emptyPath"
            '')
          }";
        };

        generations = with nixpkgs.legacyPackages.${system}; {
          type = "app";
          program = "${
            (writeShellScript "generations" ''
              set -euo pipefail
              ${home-manager.packages."${system}".home-manager}/bin/home-manager generations
            '')
          }";
        };

        remove-generations = with nixpkgs.legacyPackages.${system}; {
          type = "app";
          program = "${
            (writeShellScript "remove-generations" ''
              set -euo pipefail
              ${home-manager.packages."${system}".home-manager}/bin/home-manager remove-generations "$@"
            '')
          }";
        };
      });

      overlays.default = builtins.foldl' composeExtensions (_: _: { }) overlays;
    };
}
