# VMA

A nix shell for running VMA, the tool that proxmox uses to make backups. It is very rough and I don't plan to make improvements as I've already accomplished what I set out to do: extracted the disk image of a vm backed up with proxmox.

## Basic Usage

```bash
nix-shell
vma extract ./vzdump-qemu-600-2023_03_11-21_00_04.vma -v ./vmaextract
```
