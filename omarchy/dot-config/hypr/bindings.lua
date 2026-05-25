-- Keybindings
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER"

-- Application commands
local terminal    = "uwsm-app -- xdg-terminal-exec --dir=\"$(omarchy-cmd-terminal-cwd)\""
local browser     = "omarchy-launch-browser"
local fileManager = "uwsm-app -- nautilus --new-window"
local music       = "omarchy-launch-or-focus spotify"
local messenger   = "omarchy-launch-or-focus ^signal$ \"uwsm-app -- signal-desktop\""
local passwordManager = "uwsm-app -- 1password"
local editor      = "omarchy-launch-editor"

-------------------------------
---- APPLICATION LAUNCHERS ----
-------------------------------

-- Terminal / apps
hl.bind(mainMod .. " + ALT + RETURN", hl.dsp.exec_cmd("uwsm-app -- xdg-terminal-exec --dir=\"$(omarchy-cmd-terminal-cwd)\" tmux new"))
hl.bind(mainMod .. " + RETURN",       hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + F",     hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + ALT + SHIFT + F", hl.dsp.exec_cmd("uwsm-app -- nautilus --new-window \"$(omarchy-cmd-terminal-cwd)\""))
hl.bind(mainMod .. " + SHIFT + B",     hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + ALT + SHIFT + B", hl.dsp.exec_cmd("omarchy-launch-browser --private"))
hl.bind(mainMod .. " + SHIFT + M",     hl.dsp.exec_cmd(music))
hl.bind(mainMod .. " + ALT + SHIFT + M", hl.dsp.exec_cmd("omarchy-launch-or-focus-tui cliamp"))
hl.bind(mainMod .. " + SHIFT + N",     hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + SHIFT + T",     hl.dsp.exec_cmd("omarchy-launch-tui btop"))
hl.bind(mainMod .. " + SHIFT + D",     hl.dsp.exec_cmd("omarchy-launch-tui lazydocker"))
hl.bind(mainMod .. " + SHIFT + G",     hl.dsp.exec_cmd(messenger))
hl.bind(mainMod .. " + SHIFT + O",     hl.dsp.exec_cmd("uwsm-app -- obsidian"))
hl.bind(mainMod .. " + SHIFT + W",     hl.dsp.exec_cmd("uwsm-app -- typora --enable-wayland-ime"))
hl.bind(mainMod .. " + SHIFT + SLASH", hl.dsp.exec_cmd(passwordManager))

-- Web apps
hl.bind(mainMod .. " + SHIFT + A",         hl.dsp.exec_cmd("omarchy-launch-webapp \"https://chatgpt.com\""))
hl.bind(mainMod .. " + ALT + SHIFT + A",   hl.dsp.exec_cmd("omarchy-launch-webapp \"https://grok.com\""))
hl.bind(mainMod .. " + SHIFT + C",         hl.dsp.exec_cmd("omarchy-launch-webapp \"https://app.hey.com/calendar/weeks/\""))
hl.bind(mainMod .. " + SHIFT + E",         hl.dsp.exec_cmd("omarchy-launch-webapp \"https://app.hey.com\""))
hl.bind(mainMod .. " + SHIFT + Y",         hl.dsp.exec_cmd("omarchy-launch-webapp \"https://youtube.com/\""))
hl.bind(mainMod .. " + ALT + SHIFT + G",   hl.dsp.exec_cmd("omarchy-launch-or-focus-webapp WhatsApp \"https://web.whatsapp.com/\""))
hl.bind(mainMod .. " + CTRL + SHIFT + G",  hl.dsp.exec_cmd("omarchy-launch-or-focus-webapp \"Google Messages\" \"https://messages.google.com/web/conversations\""))
hl.bind(mainMod .. " + SHIFT + P",         hl.dsp.exec_cmd("omarchy-launch-or-focus-webapp \"Google Photos\" \"https://photos.google.com/\""))
hl.bind(mainMod .. " + SHIFT + X",         hl.dsp.exec_cmd("omarchy-launch-webapp \"https://x.com/\""))
hl.bind(mainMod .. " + ALT + SHIFT + X",   hl.dsp.exec_cmd("omarchy-launch-webapp \"https://x.com/compose/post\""))


-------------------------------
---- WINDOW MANAGEMENT ----
-------------------------------

-- Close windows
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("omarchy-hyprland-window-close-all"))

-- Tiling operations
hl.bind(mainMod .. " + J",          hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + P",          hl.dsp.window.pseudo())
hl.bind(mainMod .. " + T",          hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",          hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + CTRL + F",   hl.dsp.window.fullscreen_state({ internal = 0, client = 2, action = "set" }))
hl.bind(mainMod .. " + ALT + F",    hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + O",          hl.dsp.exec_cmd("omarchy-hyprland-window-pop"))
hl.bind(mainMod .. " + L",          hl.dsp.exec_cmd("omarchy-hyprland-workspace-layout-toggle"))

-- Focus movement
hl.bind(mainMod .. " + LEFT",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + UP",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + DOWN",  hl.dsp.focus({ direction = "d" }))

-- Workspace switching
for i = 1, 10 do
    local key = i % 10
    local ws  = i
    hl.bind(mainMod .. " + " .. key,        hl.dsp.focus({ workspace = ws }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
    hl.bind(mainMod .. " + ALT + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws, follow = false }))
end

-- Scratchpad
hl.bind(mainMod .. " + S",          hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + ALT + S",   hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Workspace navigation
hl.bind(mainMod .. " + TAB",        hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + TAB", hl.dsp.focus({ workspace = "previous" }))

-- Move workspaces between monitors
hl.bind(mainMod .. " + ALT + SHIFT + LEFT",  hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mainMod .. " + ALT + SHIFT + RIGHT", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(mainMod .. " + ALT + SHIFT + UP",    hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(mainMod .. " + ALT + SHIFT + DOWN",  hl.dsp.workspace.move({ monitor = "d" }))

-- Swap windows
hl.bind(mainMod .. " + SHIFT + LEFT",  hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + UP",    hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + DOWN",  hl.dsp.window.swap({ direction = "d" }))

-- Cycle windows / monitors
hl.bind("ALT + TAB",          hl.dsp.layout("cyclenext"))
hl.bind("ALT + SHIFT + TAB",  hl.dsp.layout("cyclenext prev"))
hl.bind("ALT + TAB",          hl.dsp.window.bring_to_top())
hl.bind("ALT + SHIFT + TAB",  hl.dsp.window.bring_to_top())
hl.bind("CTRL + ALT + TAB",        hl.dsp.focus({ monitor = "+1" }))
hl.bind("CTRL + ALT + SHIFT + TAB", hl.dsp.focus({ monitor = "-1" }))

-- Resize windows
hl.bind(mainMod .. " + code:20",         hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(mainMod .. " + code:21",         hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + code:20", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind(mainMod .. " + SHIFT + code:21", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse bindings for move/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Window groups
hl.bind(mainMod .. " + G",          hl.dsp.group.toggle())
hl.bind(mainMod .. " + ALT + G",    hl.dsp.window.move({ out_of_group = true }))
hl.bind(mainMod .. " + ALT + LEFT",  hl.dsp.window.move({ into_group = "l" }))
hl.bind(mainMod .. " + ALT + RIGHT", hl.dsp.window.move({ into_group = "r" }))
hl.bind(mainMod .. " + ALT + UP",    hl.dsp.window.move({ into_group = "u" }))
hl.bind(mainMod .. " + ALT + DOWN",  hl.dsp.window.move({ into_group = "d" }))
hl.bind(mainMod .. " + ALT + TAB",           hl.dsp.group.active({ index = 1 }))
hl.bind(mainMod .. " + ALT + SHIFT + TAB",   hl.dsp.group.active({ index = 0 }))
hl.bind(mainMod .. " + CTRL + LEFT",         hl.dsp.group.active({ index = 0 }))
hl.bind(mainMod .. " + CTRL + RIGHT",        hl.dsp.group.active({ index = 1 }))
hl.bind(mainMod .. " + ALT + mouse_down",    hl.dsp.group.active({ index = 1 }))
hl.bind(mainMod .. " + ALT + mouse_up",      hl.dsp.group.active({ index = 0 }))
for i = 1, 5 do
    hl.bind(mainMod .. " + ALT + code:" .. (9 + i), hl.dsp.group.active({ index = i }))
end

-- Cycle monitor scaling
hl.bind(mainMod .. " + code:61",        hl.dsp.exec_cmd("omarchy-hyprland-monitor-scaling-cycle"))
hl.bind(mainMod .. " + ALT + code:61",  hl.dsp.exec_cmd("omarchy-hyprland-monitor-scaling-cycle --reverse"))


-------------------------------
---- CLIPBOARD ----
-------------------------------

hl.bind(mainMod .. " + C",       hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }))
hl.bind(mainMod .. " + V",       hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }))
hl.bind(mainMod .. " + X",       hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }))
hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("omarchy-launch-walker -m clipboard"))


-------------------------------
---- MEDIA KEYS ----
-------------------------------

hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd("omarchy-swayosd-client --output-volume raise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd("omarchy-swayosd-client --output-volume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",          hl.dsp.exec_cmd("omarchy-swayosd-client --output-volume mute-toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd("omarchy-audio-input-mute"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd("omarchy-brightness-display +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd("omarchy-brightness-display 5%-"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86MonBrightnessUp",   hl.dsp.exec_cmd("omarchy-brightness-display 100%"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("omarchy-brightness-display 1%"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessUp",    hl.dsp.exec_cmd("omarchy-brightness-keyboard up"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown",  hl.dsp.exec_cmd("omarchy-brightness-keyboard down"), { locked = true, repeating = true })
hl.bind("XF86KbdLightOnOff",      hl.dsp.exec_cmd("omarchy-brightness-keyboard cycle"), { locked = true })
hl.bind("XF86TouchpadToggle",     hl.dsp.exec_cmd("omarchy-toggle-touchpad"), { locked = true })
hl.bind("XF86TouchpadOn",         hl.dsp.exec_cmd("omarchy-toggle-touchpad on"), { locked = true })
hl.bind("XF86TouchpadOff",        hl.dsp.exec_cmd("omarchy-toggle-touchpad off"), { locked = true })

-- Precise 1% adjustments with Alt
hl.bind("ALT + XF86AudioRaiseVolume",  hl.dsp.exec_cmd("omarchy-swayosd-client --output-volume +1"), { locked = true, repeating = true })
hl.bind("ALT + XF86AudioLowerVolume",  hl.dsp.exec_cmd("omarchy-swayosd-client --output-volume -1"), { locked = true, repeating = true })
hl.bind("ALT + XF86MonBrightnessUp",   hl.dsp.exec_cmd("omarchy-brightness-display +1%"), { locked = true, repeating = true })
hl.bind("ALT + XF86MonBrightnessDown", hl.dsp.exec_cmd("omarchy-brightness-display 1%-"), { locked = true, repeating = true })

-- Player controls
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("omarchy-swayosd-client --playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("omarchy-swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("omarchy-swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("omarchy-swayosd-client --playerctl previous"), { locked = true })

-- Switch audio output
hl.bind(mainMod .. " + XF86AudioMute", hl.dsp.exec_cmd("omarchy-audio-output-switch"), { locked = true })


-------------------------------
---- MENUS & UTILITIES ----
-------------------------------

-- Menus
hl.bind(mainMod .. " + SPACE",            hl.dsp.exec_cmd("omarchy-launch-walker"))
hl.bind(mainMod .. " + CTRL + E",         hl.dsp.exec_cmd("omarchy-launch-walker -m symbols"))
hl.bind(mainMod .. " + CTRL + C",         hl.dsp.exec_cmd("omarchy-menu capture"))
hl.bind(mainMod .. " + CTRL + O",         hl.dsp.exec_cmd("omarchy-menu toggle"))
hl.bind(mainMod .. " + CTRL + H",         hl.dsp.exec_cmd("omarchy-menu hardware"))
hl.bind(mainMod .. " + ALT + SPACE",      hl.dsp.exec_cmd("omarchy-menu"))
hl.bind(mainMod .. " + SHIFT + code:201", hl.dsp.exec_cmd("omarchy-menu"))
hl.bind(mainMod .. " + ESCAPE",           hl.dsp.exec_cmd("omarchy-menu system"))
hl.bind("XF86PowerOff",                   hl.dsp.exec_cmd("omarchy-menu system"), { locked = true })
hl.bind(mainMod .. " + K",               hl.dsp.exec_cmd("omarchy-menu-keybindings"))
hl.bind("XF86Calculator",                hl.dsp.exec_cmd("gnome-calculator"), { locked = true })

-- Aesthetics
hl.bind(mainMod .. " + SHIFT + SPACE",    hl.dsp.exec_cmd("omarchy-toggle-waybar"))
hl.bind(mainMod .. " + CTRL + SPACE",     hl.dsp.exec_cmd("omarchy-menu background"))
hl.bind(mainMod .. " + SHIFT + CTRL + SPACE", hl.dsp.exec_cmd("omarchy-menu theme"))
hl.bind(mainMod .. " + BACKSPACE",         hl.dsp.exec_cmd("omarchy-hyprland-window-transparency-toggle"))
hl.bind(mainMod .. " + SHIFT + BACKSPACE", hl.dsp.exec_cmd("omarchy-hyprland-window-gaps-toggle"))
hl.bind(mainMod .. " + CTRL + BACKSPACE",  hl.dsp.exec_cmd("omarchy-hyprland-window-single-square-aspect-toggle"))

-- Notifications
hl.bind(mainMod .. " + COMMA",             hl.dsp.exec_cmd("makoctl dismiss"))
hl.bind(mainMod .. " + SHIFT + COMMA",     hl.dsp.exec_cmd("makoctl dismiss --all"))
hl.bind(mainMod .. " + CTRL + COMMA",      hl.dsp.exec_cmd("omarchy-toggle-notification-silencing"))
hl.bind(mainMod .. " + ALT + COMMA",       hl.dsp.exec_cmd("makoctl invoke"))
hl.bind(mainMod .. " + ALT + SHIFT + COMMA", hl.dsp.exec_cmd("makoctl restore"))

-- Toggles
hl.bind(mainMod .. " + CTRL + I",      hl.dsp.exec_cmd("omarchy-toggle-idle"))
hl.bind(mainMod .. " + CTRL + N",      hl.dsp.exec_cmd("omarchy-toggle-nightlight"))
hl.bind(mainMod .. " + CTRL + DELETE", hl.dsp.exec_cmd("omarchy-hyprland-monitor-internal toggle"))
hl.bind(mainMod .. " + CTRL + ALT + DELETE", hl.dsp.exec_cmd("omarchy-hyprland-monitor-internal-mirror toggle"))

-- Lid switch (uses hyprctl for switch events - no hl.on equivalent)
-- hl.bind("", hl.dsp.exec_cmd("omarchy-hw-external-monitors && omarchy-hyprland-monitor-internal off"), { locked = true })
-- hl.bind("", hl.dsp.exec_cmd("omarchy-hyprland-monitor-internal on"), { locked = true })
-- Note: lid switch events are handled by the Omarchy default config via bindl syntax in hyprlang.
-- If fully migrating to Lua without the hyprlang defaults, handle these with acpid or udev rules.

-- Captures
hl.bind("PRINT",             hl.dsp.exec_cmd("omarchy-capture-screenshot"))
hl.bind("ALT + PRINT",       hl.dsp.exec_cmd("omarchy-menu screenrecord"))
hl.bind(mainMod .. " + PRINT",         hl.dsp.exec_cmd("pkill hyprpicker || hyprpicker -a"))
hl.bind(mainMod .. " + CTRL + PRINT",  hl.dsp.exec_cmd("omarchy-capture-text-extraction"))

-- File sharing
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("omarchy-menu share"))

-- Transcoding
hl.bind(mainMod .. " + CTRL + PERIOD", hl.dsp.exec_cmd("omarchy-transcode"))

-- Reminders
hl.bind(mainMod .. " + CTRL + R",         hl.dsp.exec_cmd("omarchy-menu reminder-set"))
hl.bind(mainMod .. " + CTRL + ALT + R",   hl.dsp.exec_cmd("omarchy-reminder show"))
hl.bind(mainMod .. " + SHIFT + CTRL + R", hl.dsp.exec_cmd("omarchy-reminder clear"))

-- Info displays
hl.bind(mainMod .. " + CTRL + ALT + T", hl.dsp.exec_cmd("notify-send -u low \"    $(date +\"%A %H:%M  ·  %d %B %Y  ·  Week %V\")\""))
hl.bind(mainMod .. " + CTRL + ALT + B", hl.dsp.exec_cmd("notify-send -u low \"$(omarchy-battery-status)\""))
hl.bind(mainMod .. " + CTRL + ALT + W", hl.dsp.exec_cmd("notify-send -u low \"$(omarchy-weather-status)\""))

-- Control panels
hl.bind(mainMod .. " + CTRL + A", hl.dsp.exec_cmd("omarchy-launch-audio"))
hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd("omarchy-launch-bluetooth"))
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("omarchy-launch-wifi"))
hl.bind(mainMod .. " + CTRL + T", hl.dsp.exec_cmd("omarchy-launch-tui btop"))

-- Dictation
hl.bind(mainMod .. " + CTRL + X", hl.dsp.exec_cmd("voxtype record toggle"))
hl.bind("F9",                     hl.dsp.exec_cmd("voxtype record start"))
hl.bind("F9",                     hl.dsp.exec_cmd("voxtype record stop"), { release = true })

-- Zoom
hl.bind(mainMod .. " + CTRL + Z",     hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float + 1')"))
hl.bind(mainMod .. " + CTRL + ALT + Z", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 1"))

-- Lock system
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("omarchy-system-lock"))
