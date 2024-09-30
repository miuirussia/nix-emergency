inputs: final: prev:
let
  yamlFormat = (final.formats.yaml { }).generate;

  defaultStackConfig = yamlFormat "stack.yaml" {
    templates = {
      params = {
        author-name = "Kirill Kuznetsov";
        author-email = "kdevlab@yandex.ru";
        copyright = "(C) 2024 KDevLab";
        github-username = "miuirussia";
      };
    };
    recommend-stack-upgrade = false;
    notify-if-nix-on-path = false;
    system-ghc = true;
    install-ghc = false;
    nix.enable = false;
    ghc-options."$locals" = "-optP-Wno-nonportable-include-path";
  };

  stackWithConfig =
    config:
    (final.writeScriptBin "stack" ''
      #!${final.runtimeShell}

      xdg_config_home_config_yaml="${config}"
      stack_root="$HOME/.stack"
      stack_root_config_yaml="$stack_root/config.yaml"
      if [ -f "$xdg_config_home_config_yaml" ]; then
        mkdir -p "$stack_root"
        rm -f "$stack_root_config_yaml"
        ln -sf "$xdg_config_home_config_yaml" "$stack_root_config_yaml"
      fi

      exec "${prev.stack}/bin/stack" "$@"
    '')
    // {
      name = "stack-with-config";
      version = prev.stack.version;
      meta.description = "Haskell Stack with config: ${config}";
    };
in
{
  lib = prev.lib // {
    inherit stackWithConfig;
  };

  stack = stackWithConfig defaultStackConfig;
}
