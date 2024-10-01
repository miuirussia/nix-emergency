{ pkgs, ... }: {
  nix = {
    package = pkgs.nixVersions.git;

    settings = {
      show-trace = true;
      substituters = [
        "https://cache.nixos.org/"
        "https://kdevlab.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "kdevlab.cachix.org-1:/Mxmbtc6KwP9ifFmetjkadaeeqTAtvzBXI81DGLAVIo="
      ];
      trusted-users = [
        "@wheel"
      ];
    };
  };
}
