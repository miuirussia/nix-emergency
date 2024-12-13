{ inputs, config, pkgs, ... }: {
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;

    controlMaster = "auto";
    forwardAgent = true;
    serverAliveInterval = 60;
    hashKnownHosts = true;

    matchBlocks = {
      "*" = {
        identityFile = [
          "${config.home.homeDirectory}/.ssh/id_ed25519"
        ];
      };

      "git.termt.com" = {
        user = "git";
        port = 61722;
      };
    };
  };
} 
