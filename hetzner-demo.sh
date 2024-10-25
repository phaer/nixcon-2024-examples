#!/usr/bin/env bash

set -x

# Use a dedicated SSH private key for this example
ssh_key_file="$HOME/.ssh/workshop-example"

# Let Hetzner know about our SSH key if it does not already
if ! hcloud ssh-key describe "workshop-example" > /dev/null
then
    hcloud ssh-key create \
        --name "workshop-example" \
        --public-key-from-file "$ssh_key_file.pub"
fi

# Delete the server "workshop-example" if it exists already
hcloud server delete "workshop-example"

# And create it anew: A CX22 instance, named "workshop example", running Ubuntu 24.0
# with our SSH key provisioned.
target_server="$( \
    hcloud server create \
    --name "workshop-example" \
    --type "cx22" \
    --image "ubuntu-24.04" \
    --ssh-key "workshop-example" \
    --output json \
)"

# Get the Servers IPv4 adress from hcloud's output.
target_ip="$(echo "$target_server" | jq -r ".server.public_net.ipv4.ip")"

# Wait until the server has SSHD up and running by trying to connect in a loop
until
    ssh \
        -o ConnectTimeout=5 \
        -o "UserKnownHostsFile=/dev/null" \
        -o "StrictHostKeyChecking=no" \
        -i "$ssh_key_file" \
        "root@$target_ip" uname 2>&1 > /dev/null
do
    sleep 1
done

# Finally, run nixos-anywhere.
# Hetzner Cloud does not support UEFI yet (their dedicated servers do), so we use legacy boot/MBR.
# We also:
# - specify our dedicated SSH key
# - ask nixos-anywhere to generate a report on what hardware the target machine has via nixos-facter
# - ask nixos-anywhere to build our closure on the remote host instead of doing so locally and uploading
#   it. That's a cheap trick that makes it easier to deploy from darwin or foreign architectures.
nixos-anywhere -L \
    --flake .#example-mbr \
    -i "$ssh_key_file" \
    --generate-hardware-config nixos-facter facter.json \
    --build-on-remote \
    "root@$target_ip"

# Suggest an SSH command for convenience.
cat <<EOF
Server's ready:

    ssh -o ConnectTimeout=5 -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i "$ssh_key_file" "root@$target_ip"
EOF
