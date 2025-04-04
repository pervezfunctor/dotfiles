local wezterm = require 'wezterm'

return {
  color_scheme = 'Catppuccin Mocha',
  window_padding = {
    left = 2,
    right = 2,
    top = 0,
    bottom = 0,
  },
  adjust_window_size_when_changing_font_size = false,
  enable_tab_bar = false,
  font_size = 12.0,
  font = wezterm.font('JetBrainsMono Nerd Font'),
  macos_window_background_blur = 30,
  window_background_opacity = 0.9,
  window_close_confirmation = 'NeverPrompt',

  default_prog = { 'wsl', '-d', 'CentOS-Stream-10', '--cd', '~' },
  mouse_bindings = {
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
  },
}
