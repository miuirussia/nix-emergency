inputs: final: prev:

rec {
  vscode-mp-extensions =
    with builtins;
    [
      # prev.vscode-extensions.rust-lang.rust-analyzer
      (import ./codelldb { pkgs = prev; })
      (import ./continue { pkgs = prev; })
    ]
    ++ prev.vscode-utils.extensionsFromVscodeMarketplace (fromJSON (readFile ./extensions.json));

  vscode-custom = prev.vscode-with-extensions.override {
    vscode = prev.vscodium;
    vscodeExtensions = vscode-mp-extensions;
  };
}
