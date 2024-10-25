#!/usr/bin/env sh

# Use a dedicated SSH private key for this example
ssh_key_file="$HOME/.ssh/workshop-example"

nixos-anywhere -L \
    -f .#example-uefi \
    -i "$ssh_key_file" \
    --post-kexec-ssh-port 2222 \
    --ssh-port 2222 \
    "root@localhost"
