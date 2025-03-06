local wezterm = require 'wezterm'

return {
	adjust_window_size_when_changing_font_size = false,
	color_scheme = 'Catppuccin Mocha',
	enable_tab_bar = false,
	font_size = 10.0,
	font = wezterm.font('JetBrains Mono'),
	macos_window_background_blur = 30,
	window_background_opacity = 0.9,
	-- window_decorations = 'RESIZE',
	window_close_confirmation = 'NeverPrompt',
	-- keys = {
		-- {
		-- 	key = 'q',
		-- 	mods = 'CTRL',
		-- 	action = wezterm.action.ToggleFullScreen,
		-- },
	-- },

	mouse_bindings = {
	  {
	    event = { Up = { streak = 1, button = 'Left' } },
	    mods = 'CTRL',
	    action = wezterm.action.OpenLinkAtMouseCursor,
	  },
	},
}

