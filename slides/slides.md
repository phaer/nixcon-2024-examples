---
author: Paul Haerle
title: Deploy NixOS remotely with nixos-anywhere & disko
subtitle: On hetzner.cloud, with ZFS.
date: 2024-10-26
---

# Agenda

* Who am I?
* What's nixos-anywhere?
* What's disko?
* Demo time - let's install NixOS on a hetzner.cloud box!
* Questions & Answers

# Who am I?

![Picture of @phaer](./slides/me.webp){.logo .me}

* **@phaer** on github.com, matrix.org, fosstodon.org, etc.
* Set up far too many boxes by hand in 15+ years of herding Linux machines.
* Contributor to nixos-anywhere & disko since 2022.
* <small>Candidate for Nix Steering Committee</small>


# What's `nixos-anywhere`?

![nixos-anywhere](./slides/nixos-anywhere.png){.logo}

* Bash script for unattended installation of NixOS on remote hosts
* Just needs SSH & either kexec-enabled kernel or booted installer
* Presented at NixCon 2023 by @Mic92 and @lassulus.

## How does it work?

* Connect to target host via SSH
* Gather facts about remote system
* If not already in installer: Download image & `kexec` into it
* Run `diskoScript` to setup file systems
* Run `nixos-install`
* Reboot into new system

## Useful features

* Upload `--disk-encryption-keys` before formatting
* Upload `--extra-files` into the installed system (i.e. ssh host keys)
* `--generate-hardware-config` 
* Bring your own `--kexec` installer image
* `--build-on-remote` instead of uploading closures
* Validate your config with `--vm-test`
* ...and don't forget to `--debug`!

## `nixos-anywhere` vs `nixos-infect`?

Feature                           nixos-infect    nixos-anywhere
--------                          -------------   ---------------
Install NixOS on a remote server  ✅              ✅
BYO partition layout              ❌              ✅
fancy file systems (ZFS, etc)     ❌              ✅
cloud-init                        ✅              ❌ 


# What's `disko`?

![disko](./slides/disko.png){.logo}

* Converts declarative disk layouts into bespoke bash scripts to format your disks
* Supports mbr & gpt, lvm, mdadm, luks, zfs, btrfs, bcachefs
* Can be used as NixOS module or standalone cli

## Useful features

* Build images with `system.build.diskoImages{Script,}`
* Run arbitrary commands during setup with hooks, i.e. `postCreateHook`
* `system.build.vmWithDisko`

## `disko` vs `systemd-repart`

Feature                           disko           systemd-repart 
--------                          -------------   ---------------
Multiple Disks                    ✅              ❌ 
Legacy Boot (MBR)                 ✅              ❌ 
ZFS, LVM, etc                     ✅              ❌ 
Lots of Bash                      ✅              ❌


# Demo Time!

https://github.com/phaer/nixcon-2024-examples


# Thanks for joining!

- https://github.com/nix-community/nixos-anywhere
- https://github.com/nix-community/disko
- https://github.com/nix-community/disko-templates
- https://media.ccc.de/v/nixcon-2023-35975-disko-and-nixos-anywhere-declarative-and-remote-installation-of-nixos
