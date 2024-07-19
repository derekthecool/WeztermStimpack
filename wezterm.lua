-- My configuration WeztermStimpack
require('WeztermStimpack.right-status-format')
require('WeztermStimpack.gui-startup')

local config = {}

require('WeztermStimpack.bell-settings').init(config)
require('WeztermStimpack.font-settings').init(config)
require('WeztermStimpack.tab-format').init(config)
config.ssh_domains = require('WeztermStimpack.ssh-domains')
config.colors = require('WeztermStimpack.colors')
config.window_close_confirmation = 'NeverPrompt'

-- Visual settings
config.color_scheme = 'Atelier Sulphurpool (base16)' -- Same as my neovim config
config.window_background_opacity = 0.72
config.window_decorations = 'RESIZE' -- No title bar, but allow window resize with mouse
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 } -- No padding
config.show_update_window = false

-- Use pwsh as default shell
config.default_prog = { 'pwsh' }
config.exit_behavior = 'CloseOnCleanExit'

-- Easy picks for steno keyboard
config.quick_select_alphabet = '1234567890'
config.quick_select_patterns = require('WeztermStimpack.quick-select-patterns')

-- Set leader, disable defaults, load keymap files
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 2000 }
config.disable_default_key_bindings = true
config.keys = require('WeztermStimpack.keymaps').collect_keymap_files()
config.key_tables = require('WeztermStimpack.keymap-tables')

return config
