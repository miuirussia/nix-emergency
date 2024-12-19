{ pkgs }:

pkgs.vscode-utils.buildVscodeMarketplaceExtension {
  vsix = ./continue-0.9.246.zip;

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    libgcc
    stdenv.cc.cc.lib
    zlib
  ];

  mktplcRef = {
    publisher = "Continue";
    name = "continue";
    version = "0.9.246";
  };
}
