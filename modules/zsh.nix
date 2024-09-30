{ pkgs, ... }:

{
  programs.fzf = {
    enable = true;

    enableBashIntegration = false;
    enableZshIntegration = false;

    tmux.enableShellIntegration = false;
  };

  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      "nix_shell" = {
        format = "[$symbol$state($name)]($style) ";
        symbol = "❄️ ";
        impure_msg = "";
      };
      "git_status" = {
        diverged = "↑$ahead_count↓$behind_count";
        conflicted = " \${count|";
        ahead = "↑ \${count}";
        behind = "↓ \${count}";
      };
    };
  };

  programs.zsh = {
    enable = true;

    autocd = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = false;

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    cdpath = [
      "."
      "~"
    ];

    plugins = with pkgs.zshPlugins; [
      fast-syntax-highlighting
      zsh-history-substring-search
      zsh-yarn-completions
    ];

    shellAliases = {
      wip = "g add -u && g commit -m \"wip\" && g fetch --all && g pull --rebase && g push";

      e = "nvim";
      g = "git";
      grep = "grep --color";
      password = "LC_CTYPE=C tr -dc 'A-HJ-NPR-Za-km-z2-9' < /dev/urandom | head -c 16";
      clc = "clear && printf \"\\033[3J\"";
      srv = "pnpx -y serve";

      ":r" = "exec $SHELL -l";
      ":q" = "exit";
    };

    defaultKeymap = "viins";
    dotDir = ".config/zsh";

    envExtra = ''
      export NVIM_LOG_FILE=/dev/null

      typeset -U path PATH
      path=(~/.local/bin $path)
      export PATH

      export LC_ALL="en_US.UTF-8";
      export LANG="en_US.UTF-8";
    '';

    initExtra = ''
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

      export KEYTIMEOUT=1

      vi-search-fix() {
        zle vi-cmd-mode
        zle .vi-history-search-backward
      }

      autoload vi-search-fix
      zle -N vi-search-fix
      bindkey -M viins '\e/' vi-search-fix

      bindkey "^?" backward-delete-char

      resume() {
        fg
        zle push-input
        BUFFER=""
        zle accept-line
      }
      zle -N resume
      bindkey "^Z" resume

      ls() {
        ${pkgs.coreutils}/bin/ls --color=auto --group-directories-first "$@"
      }

      # Get gzipped file size
      gz() {
        local ORIGSIZE=$(wc -c < "$1")
        local GZIPSIZE=$(gzip -c "$1" | wc -c)
        local RATIO=$(echo "$GZIPSIZE * 100/ $ORIGSIZE" | bc -l)
        local SAVED=$(echo "($ORIGSIZE - $GZIPSIZE) * 100/ $ORIGSIZE" | bc -l)
        printf "orig: %d bytes\ngzip: %d bytes\nsave: %2.0f%% (%2.0f%%)\n" "$ORIGSIZE" "$GZIPSIZE" "$SAVED" "$RATIO"
      }

      timestamp() {
        if [ $# -ne 1 ];
        then
          echo $(( EPOCHSECONDS ))
        else
          date -d @$1
        fi
      }

      # Get IP from hostname
      hostname2ip() {
        ping -c 1 "$1" | egrep -m1 -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
      }

      # mkdir and cd into it
      mk() {
        mkdir -p $@ && cd $_;
      }

      search_and_execute() {
        local folder="$1"
        local filename="$2"
        local command="$3"

        find "$folder" -type f -name "$filename" -exec "$command" {} ;
      }

      materialize() {
        local symlinkFile="$1"
        local realFile=$(readlink -f $symlinkFile)

        rm "$symlinkFile"
        if [ -d $realFile ]; then
          cp -R "$realFile" "$symlinkFile"
        else
          cp "$realFile" "$symlinkFile"
        fi
      }

      c() {
        printf "%s\n" "$@" | ${pkgs.bc}/bin/bc -l;
      }

      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
    '';
  };
}
