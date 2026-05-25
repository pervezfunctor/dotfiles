-- Autostart
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function ()
    hl.exec_cmd("uwsm-app -- hypridle")
    hl.exec_cmd("uwsm-app -- mako")
    hl.exec_cmd("! omarchy-toggle-enabled waybar-off && uwsm-app -- waybar")
    hl.exec_cmd("uwsm-app -- fcitx5 --disable notificationitem")
    hl.exec_cmd("uwsm-app -- swaybg -i ~/.config/omarchy/current/background -m fill")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("omarchy-first-run")
    hl.exec_cmd("omarchy-powerprofiles-init")
    hl.exec_cmd("uwsm-app -- omarchy-hyprland-monitor-watch")
    hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("sleep 2 && omarchy-hook post-boot")
end)
