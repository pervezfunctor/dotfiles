#! /usr/bin/env bash

export XCURSOR_SIZE=32
export CLUTTER_BACKEND=wayland
export GDK_BACKEND=wayland,x11
export QT_AUTO_SCREEN_SCALE_FACTOR=1.5
# export # QT_QPA_PLATFORM=wayland;xcb
# export #=QT_QPA_PLATFORMTHEME,qt5ct
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_SCALE_FACTOR=1.5
# export #=QT_WAYLAND_DISABLE_WINDOWDECORATION,1
export XDG_SESSION_TYPE=wayland

# export #=GDK_SCALE,1
export MOZ_ENABLE_WAYLAND=1

# electron >28 apps (may help)`
export ELECTRON_OZONE_PLATFORM_HINT=auto
export OZONE_PLATFORM=wayland
export ELECTRON_OZONE_PLATFORM_HINT=wayland

# export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/gcr/ssh"
# export GNOME_KEYRING_CONTROL="${XDG_RUNTIME_DIR}/keyring"
export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:~/.local/share/flatpak/exports/share
