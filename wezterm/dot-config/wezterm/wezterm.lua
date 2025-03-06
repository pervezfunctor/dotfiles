local wezterm = require 'wezterm'

return {
	color_scheme = 'Everforest Dark (Gogh)',
	-- color_scheme = 'Catpaccuing Mocha',
	-- color_scheme = 'Rosé Pine Dawn (Gogh)',
	-- color_scheme = 'Rosé Pine Dawn (Gogh)',
	-- color_scheme = 'Everforest Light (Gogh)',
	-- config.color_scheme = 'Github Dark (Gogh)',

	adjust_window_size_when_changing_font_size = false,
	enable_tab_bar = false,
	font_size = 10.0,
	font = wezterm.font('JetBrains Mono'),
	macos_window_background_blur = 30,
	window_background_opacity = 0.9,
	window_close_confirmation = 'NeverPrompt',

	-- window_decorations = 'RESIZE',
	-- window_background_image = '/path/to/wallpaper.jpg'
	-- text_background_opacity = 0.3

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

