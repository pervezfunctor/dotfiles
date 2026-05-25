-- Input devices
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "caps:ctrl_modifier",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0,

        repeat_rate     = 40,
        repeat_delay    = 600,
        numlock_by_default = true,

        touchpad = {
            natural_scroll = false,
            scroll_factor  = 0.4,
        },
    },

    misc = {
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,
    },
})

-- Touchpad scroll factor for terminals
hl.window_rule({
    match = { class = "(Alacritty|kitty|foot)" },
    scroll_touchpad = 1.5,
})

hl.window_rule({
    match = { class = "com.mitchellh.ghostty" },
    scroll_touchpad = 0.2,
})
