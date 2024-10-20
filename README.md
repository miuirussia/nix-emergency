# nix-emergency

On OSes other than NixOS, I was able to work around this issue by editing the nix-daemon service:

```
sudo systemctl edit nixos-daemon.service;
sudo systemctl restart nixos-daemon.service;
```

And adding the following overrides to the service definition:

```
[Service]
Environment=TMPDIR=/var/tmp/nix
ExecStartPre=mkdir -p $TMPDIR
```
