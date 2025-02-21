{ inputs, config, pkgs, ... }: {
  home.file.".config/nixpkgs/overlays.nix".text = ''
   let
      configuration = import ${inputs.self};
    in
    [ configuration.overlays.default ]
  '';
}
