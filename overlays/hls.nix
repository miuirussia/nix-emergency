inputs: final: prev:

{
  hls =
    (prev.haskell-language-server.override {
      supportedGhcVersions = [
        "902"
        "928"
        "948"
        "964"
        "965"
      ];
    }).overrideAttrs
      (oldAttrs: {
        buildInputs = oldAttrs.buildInputs or [ ] ++ [ prev.makeWrapper ];
        buildCommand =
          oldAttrs.buildCommand or ""
          + ''
            wrapProgram $out/bin/haskell-language-server-wrapper \
              --prefix PATH : $out/bin
          '';
      });
}
