{ config, pkgs, lib, ... }:

let
  nixGL = import ../lib/nixGL.nix { inherit config pkgs; };
  app = nixGL pkgs.yandex-browser-stable;
in {
  home.packages = [ app ];

  xdg.desktopEntries = {
   yandex-browser = {
      name = "Yandex Browser";
      genericName = "Web Browser";
      exec = "${lib.getExe' app "yandex-browser-stable"} %U";
      terminal = false;
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
  };
}
