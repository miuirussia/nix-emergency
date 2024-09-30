inputs: final: prev:

let
  hls-pkgs = inputs.nixpkgs-hls.legacyPackages.${prev.system};
in
{
  haskell = prev.haskell // {
    packages = prev.haskell.packages // {
      ghc902 = prev.haskell.packages.ghc902 // {
        haskell-language-server = hls-pkgs.haskell.packages.ghc902.haskell-language-server;
      };
    };
  };
}
