#!/usr/bin/env bash

# shellcheck disable=SC1091
source "$HOME"/.ilm/share/utils

is_fedora || return

/usr/bin/xdg-user-dirs-update
/usr/libexec/sway-systemd/wait-sni-ready && systemctl --user start sway-xdg-autostart.target
/usr/libexec/sway-systemd/assign-cgroups.py
/usr/libexec/sway-systemd/session.sh
has_cmd gnome-keyring-daemon && gnome-keyring-daemon -s -d --components=pkcs11,secrets,ssh
