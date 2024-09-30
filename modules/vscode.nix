hm@{ config, pkgs, ... }:

let
  nixGL = import ../lib/nixGL.nix { inherit config pkgs; };
in {
  programs.vscode = {
    enable = true;

    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;

    package = nixGL (pkgs.vscode-custom.overrideAttrs (prev: { pname = "vscodium"; }));

    userSettings = (import ../configs/vscode.nix hm);
  };
}
