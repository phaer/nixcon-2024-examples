# Examples for a Workshop on nixos-anywhere & disko at NixCon 2024

``` text
├───devShells
│   ├───aarch64-darwin
│   │   └───default: development environment 'nix-shell'
├───nixosConfigurations
│   ├───example-mbr: NixOS configuration
│   ├───example-uefi: NixOS configuration
│   └───random-linux-machine: NixOS configuration
└───nixosModules
    └───shared: NixOS module
```

## hetzner-demo.sh

Simple shell script to create a new CX22 instance on hetzner.cloud and install
`.#nixosConfigurations.mbr-example` on it.

To use it:

* Make sure `HCLOUD_TOKEN` is set to an auth token from https://hetzner.cloud.
* Either generate an ssh key pair in `$HOME/.ssh/workshop-example{,.pub}` or adapt `ssh_key_file` in the demo script.
* Change `sshKeys` in flake.nix to contain your public key.
* Run `bash hetzner-demo.sh`
* ???
* Peace, Love & Happiness.

## vm-demo.sh

* Start a basic NixOS VM, which is meant to simulate a random Linux machine running SSH - not necessarily NixOS:

``` sh
nix run .\#nixosConfigurations.random-linux-machine.config.system.build.vm
```

* Either generate an ssh key pair in `$HOME/.ssh/workshop-example{,.pub}` or adapt `ssh_key_file` in the demo script.
* Change `sshKeys` in flake.nix to contain your public key.
* Run `bash vm-demo.sh`
* ???
* Peace, Love & Happiness.


# Reference

* [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
* [disko](https://github.com/nix-community/disko)
* [disko-templates](https://github.com/nix-community/disko-templates)
* [NixCon 2023 Talk by Mic92 & lassulus](https://media.ccc.de/v/nixcon-2023-35975-disko-and-nixos-anywhere-declarative-and-remote-installation-of-nixos)
