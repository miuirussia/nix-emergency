{ inputs, ... }: {
  xdg.configFile."nixpkgs/overlays.nix".text = ''
   let
      configuration = import ${inputs.self};
    in
    [ configuration.overlays.default ]
  '';
}
