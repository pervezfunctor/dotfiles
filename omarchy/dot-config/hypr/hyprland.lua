-- Main Hyprland Lua config
--
-- To activate: rename hyprland.conf to hyprland.conf.bak
-- and rename this file to hyprland.lua (or hyprland.conf if Hyprland
-- supports .lua sourcing from .conf).
--
-- See https://wiki.hypr.land/Configuring/Start/

require("envs")
require("monitors")
require("input")
require("looknfeel")
require("windows")
require("bindings")
require("autostart")

-- Theme border color override (from ~/.config/omarchy/current/theme/hyprland.conf)
hl.config({
    general = {
        col = {
            active_border = "rgb(81a1c1)",
        },
    },
    group = {
        col = {
            border_active = "rgb(81a1c1)",
        },
    },
})
