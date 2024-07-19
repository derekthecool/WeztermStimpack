-- My configuration WeztermStimpack modules
local keymap_tables = require('WeztermStimpack.keymap-tables')
local crossplatform = require('WeztermStimpack.crossplatform')
require('WeztermStimpack.right-status-format')
require('WeztermStimpack.gui-startup')

local config = {}

require('WeztermStimpack.bell-settings').init(config)
require('WeztermStimpack.font-settings').init(config)
require('WeztermStimpack.tab-format').init(config)
config.ssh_domains = require('WeztermStimpack.ssh-domains')
config.colors = require('WeztermStimpack.colors')
config.window_close_confirmation = 'NeverPrompt'

-- Use the same color scheme as neovim
config.color_scheme = 'Atelier Sulphurpool (base16)'
-- Slightly translucent background
config.window_background_opacity = 0.72

-- Set different default shell
config.default_prog = { 'pwsh' }

-- Give me my precious terminal space back by having no padding and no title bar
config.window_decorations = 'RESIZE'
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- exit_behavior can be Close, Hold, CloseOnCleanExit, Close
config.exit_behavior = 'CloseOnCleanExit'

-- Easy picks for steno keyboard
config.quick_select_alphabet = '1234567890'
config.quick_select_patterns = require('WeztermStimpack.quick-select-patterns')

-- Set leader key
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 2000 }

-- Disable all default key maps
config.disable_default_key_bindings = true
config.keys = require('WeztermStimpack.keymaps').collect_keymap_files()

-- Assign keymap tables which are special map modal mappings
config.key_tables = keymap_tables

config.show_update_window = false

return config
