-- Wezterm modules
local wezterm = require('wezterm')
local mux = wezterm.mux

-- My configuration WeztermStimpack modules
local keymap_tables = require('WeztermStimpack.keymap-tables')
local ssh_domains = require('WeztermStimpack.ssh-domains')
local crossplatform = require('WeztermStimpack.crossplatform')
require('WeztermStimpack.right-status-format')

-- Build my default set of sessions, tabs, etc.
wezterm.on('gui-startup', function(cmd)
    local args = {}
    if cmd then
        args = cmd.args
    end

    local workspaces = {
        'CommandStation',
    }

    -- Set a workspace for coding on a current project
    -- Top pane is for the editor, bottom pane is for the build tool
    local tab, build_pane, window = mux.spawn_window({
        workspace = workspaces[1],
        cwd = string.format('%s/.mywiki', wezterm.home_dir),
        args = args,
    })

    -- Open neovim to wezterm config
    build_pane:send_text('nvim README.md\r\n')
    tab:set_title('CommandStation')

    -- -- My wiki
    -- -- Prefer jumping between mywiki, neovim, wezterm, and Plover inside neovim rather than wezterm tabs
    -- local wikiTab, wikiPane, wikiWindow = window:spawn_tab({ cwd = string.format('%s/.mywiki', wezterm.home_dir) })
    -- wikiPane:send_text('nvim README.md\r\n')
    -- wikiTab:set_title('Wiki')

    -- Example of splitting the window
    -- local editor_pane = build_pane:split {
    --   direction = 'Top',
    --   size = 0.6,
    --   cwd = os.getenv('USERPROFILE') .. [[\.workspacer]],
    -- }

    -- Build project directories as found in the directory ./projects/*.lua
    -- local project_directory_files = wezterm.read_dir(crossplatform.path.join_path(wezterm.config_dir, 'projects'))
    local project_directory_files = wezterm.read_dir(string.format('%s/projects', wezterm.config_dir))

    for i, path in ipairs(project_directory_files) do
        wezterm.log_info(string.format('File number %d = %s', i, path))

        local check_for_lua_file = path:match('(projects.*)%.lua')
        if check_for_lua_file ~= nil then
            check_for_lua_file = check_for_lua_file:gsub('[\\/]', '.')
            print('Running command: require ' .. check_for_lua_file)
            require(check_for_lua_file)
        end
    end

    mux.set_active_workspace(workspaces[1])
end)

local config = {}

require('WeztermStimpack.bell-settings').init(config)
require('WeztermStimpack.font-settings').init(config)
require('WeztermStimpack.tab-format').init(config)
config.colors = require('WeztermStimpack.colors')
config.window_close_confirmation = 'NeverPrompt'

-- Use the same color scheme as neovim
config.color_scheme = 'Atelier Sulphurpool (base16)'

-- Set different default shell
config.default_prog = { 'pwsh' }

-- Give me my precious terminal space back by having no padding and no title bar
config.window_decorations = 'RESIZE'
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- Slightly translucent background
config.window_background_opacity = 0.72

-- exit_behavior can be Close, Hold, CloseOnCleanExit, Close
-- Hold is the most forgiving as it does not autoshut down and helps detect errors
-- Hold also requires a manual closing of the tab or pane
config.exit_behavior = 'CloseOnCleanExit'

config.ssh_domains = ssh_domains

-- Easy picks for steno keyboard
config.quick_select_alphabet = '1234567890'

-- Add to list of quick select patterns
-- Not limited to lua matching, we can use rust regex wahoo!
config.quick_select_patterns = {
    -- Windows paths
    '[C-Z]:\\S+',

    -- Command-line args from help print outs
    '--\\S+',

    -- IMEI numbers
    [[\b\d{15}\b]],

    -- ICCID numbers
    [[\b\d{20}\b]],
}

-- Set leader key
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 2000 }

-- Disable all default key maps
config.disable_default_key_bindings = true

local keymap_dir = string.format('%s/WeztermStimpack/keymaps', wezterm.config_dir)
wezterm.log_info(string.format('Wezterm keymap directory file path: %s', keymap_dir))

local full_keymap_table = {}

for _, keymap_file in ipairs(wezterm.read_dir(keymap_dir)) do
    local keymap_match = keymap_file:match('(WeztermStimpack.*)%.lua')
    if keymap_match ~= nil then
        keymap_match = keymap_match:gsub('[\\/]', '.')
        print('Running command: require ' .. keymap_match)
        local sourced_keymap_file = require(keymap_match)

        if sourced_keymap_file and type(sourced_keymap_file) == 'table' then
            wezterm.log_info(
                string.format(
                    'Valid keymap file found containing: %d items, path: %s',
                    #sourced_keymap_file,
                    keymap_file
                )
            )

            for _, keymap_item in pairs(sourced_keymap_file) do
                table.insert(full_keymap_table, keymap_item)
            end

            wezterm.log_info(string.format('full_keymap_table now has: %d items', #full_keymap_table))
        else
            wezterm.log_info(
                string.format('The file: %s, did not return a table - this will not be sourced', sourced_keymap_file)
            )
        end
    end
end

-- Assign keymaps
if type(full_keymap_table) == 'table' and #full_keymap_table > 0 then
    config.keys = full_keymap_table
end

-- Assign keymap tables which are special map modal mappings
config.key_tables = keymap_tables

config.show_update_window = false

return config
