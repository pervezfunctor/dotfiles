local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'Batman'

config.font = wezterm.font 'MonaspiceRn Nerd Font Mono'

config.font_size = 14.0

return config
