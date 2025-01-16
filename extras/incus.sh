#! /usr/bin/env bash

incus_containers() {
  incus launch images:ubuntu/24.04 ubuntu # --config limits.cpu=1 --config limits.memory=192MiB
  incus launch images:fedora/41 fedora
  incus launch images:opensuse/tumbleweed tumbleweed
  incus launch images:archlinux/current archlinux
}

incus_vms() {
  incus launch images:ubuntu/24.04 ubuntu-vm --vm
  incus launch images:fedora/41 fedora-vm --vm
  incus launch images:opensuse/tumbleweed-vm tumbleweed --vm
  incus launch images:archlinux/current archlinux-vm --vm
}

