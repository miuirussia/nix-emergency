inputs: final: prev: {
  nixUnstable = final.lowPrio (
    inputs.nix-unstable.packages.${prev.system}.default.overrideAttrs (_: {
      doCheck = false;
    })
  );
}
