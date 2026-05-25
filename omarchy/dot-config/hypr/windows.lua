-- Window rules
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Suppress maximize events from all apps
hl.window_rule({
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Tag all windows for default opacity
hl.window_rule({
    match = { class = ".*" },
    tag = "+default-opacity",
})

-- Fix XWayland drag issues
hl.window_rule({
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- App-specific tweaks
-- Add per-app window rules here

-- Default opacity for tagged windows
hl.window_rule({
    match = { tag = "default-opacity" },
    opacity = "0.97 0.9",
})
