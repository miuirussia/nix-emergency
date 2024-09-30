{ config, pkgs, ... }:

let
  home_directory = "${config.home.homeDirectory}";
in
{
  imports = [
    ./modules/git.nix
  ];

  home.stateVersion = "23.05";

  home.packages = with pkgs; [
    nodePackages.pnpm
    pnpm-shell-completion
    nodePackages.yarn
    nodejs-slim
    tree
  ];

  home.file = { };

  home.sessionVariables = {
    PAGER = "${pkgs.less}/bin/less";
    CLICOLOR = 1;
  };

  xdg = {
    enable = true;

    configHome = "${home_directory}/.config";
    dataHome = "${home_directory}/.data";
    cacheHome = "${home_directory}/.cache";
    systemDirs.data = [
      "${home_directory}/.nix-profile/share"
      "${home_directory}/.share"
    ];
  };

  programs.home-manager.enable = false;
}