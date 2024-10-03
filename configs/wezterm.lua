local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'OneDark (base16)'
config.default_prog = { 'zsh' }

return config
