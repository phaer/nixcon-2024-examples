{
  description = "nixcon 2024 workshop on nixos-anywhere & disko";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
    nixos-anywhere.inputs.disko.follows = "disko";
  };

  outputs = { self, nixpkgs, disko, nixos-anywhere }:
    let
      # TODO: Change me!
      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKwyuhFaPgcO3R98R/pU94waUAOdR1kDqB3PFHbUTxm workshop-example"
      ];

      # Helper function to get the devShell working on all those systems.
      supportedSystems =
        [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_46-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = [
              # While nixos-anywhere is packaged in nixpkgs, we use the latest version
              # for --generate-hardware-config
              nixos-anywhere.packages.${system}.nixos-anywhere
              # Packages used in demo.sh
              pkgs.jq
              pkgs.hcloud
            ];
          };
        });

      nixosModules = {
        shared = { modulesPath, ... }: {
          imports = [
            "${modulesPath}/profiles/qemu-guest.nix"
            "${modulesPath}/profiles/minimal.nix"
          ];
          config = {

            services.openssh.enable = true;
            users.users.root.openssh.authorizedKeys.keys = sshKeys;
            system.stateVersion = "24.11";
            boot.loader.grub.enable = true;

          };
        };
      };

      nixosConfigurations.example-mbr =
        nixpkgs.legacyPackages.x86_64-linux.nixos {
          imports = [
            self.nixosModules.shared
            disko.nixosModules.default
            ./disko-config.nix
          ];

          networking.hostName = "example-mbr";
          networking.hostId = "7d069869";
          disko.devices.disk.main.device = "/dev/sda";
        };

      nixosConfigurations.example-uefi =
        nixpkgs.legacyPackages.x86_64-linux.nixos {
          imports = [
            self.nixosModules.shared
            disko.nixosModules.default
            ./disko-config.nix
          ];

          networking.hostName = "example-uefi";
          networking.hostId = "7d069868";

          boot.kernelParams = [ "console=ttyS0,115200" ];
          boot.loader.grub.efiSupport = true;
          boot.loader.grub.efiInstallAsRemovable = true;

          disko.devices.disk.main.device = "/dev/vda";
        };

      nixosConfigurations.random-linux-machine =
        nixpkgs.legacyPackages.x86_64-linux.nixos ({ modulesPath, ... }: {
          imports = [
            self.nixosModules.shared
            "${modulesPath}/virtualisation/qemu-vm.nix"
          ];

          boot.kernelParams = [ "console=ttyS0,115200" ];
          boot.loader.grub.efiSupport = true;
          boot.loader.grub.efiInstallAsRemovable = true;

          virtualisation = {
            useEFIBoot = true;
            useBootLoader = true;
            graphics = false;
            memorySize = 1024 * 4;
            diskSize = 1024 * 5;
            forwardPorts = [{
              from = "host";
              host.port = 2222;
              guest.port = 22;
            }];
          };
        });
    };
}
