-- Wezterm modules
local wezterm = require('wezterm')
local mux = wezterm.mux

-- My configuration WeztermStimpack modules
local colors = require('WeztermStimpack.colors')
local keymaps = require('WeztermStimpack.keymaps')
local keymap_tables = require('WeztermStimpack.keymap-tables')
local ssh_domains = require('WeztermStimpack.ssh-domains')
local crossplatform = require('WeztermStimpack.crossplatform')

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
    local title = tab_info.tab_title
    -- if the tab title is explicitly set, take that
    if title and #title > 0 then
        return title
    end
    -- Otherwise, use the title from the active pane
    -- in that tab
    return tab_info.active_pane.title
end

-- Allow custom tab rename
-- Early versions did not support this, yay now we have it!
-- https://wezfurlong.org/wezterm/config/lua/keyassignment/PromptInputLine.html?h=
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local pane_title = tab_title(tab)

    local left_icon = ''
    local right_icon = ''

    local edge_background = '#0000ff'
    local edge_foreground = '#ff0fff'

    local full_background = require('WeztermStimpack.colors').tab_bar.background
    local background = require('WeztermStimpack.colors').tab_bar.inactive_tab.bg_color
    local foreground = background

    if tab.is_active then
        background = full_background
    elseif hover then
        background = require('WeztermStimpack.colors').tab_bar.inactive_tab_hover.bg_color
    end

    return {
        { Background = { Color = full_background } },
        { Foreground = { Color = background } },
        { Text = left_icon },
        'ResetAttributes',
        { Text = pane_title },
        { Background = { Color = full_background } },
        'ResetAttributes',
        { Background = { Color = full_background } },
        { Foreground = { Color = background } },
        { Text = right_icon },
        { Text = ' ' },
    }
end)

wezterm.on('bell', function(window, pane)
    -- TODO: change highlight of tab if not current like tmux
    wezterm.log_info('the bell was rung in pane ' .. pane:pane_id() .. '!')
end)

wezterm.on('update-right-status', function(window, pane)
    local cwd_uri = pane:get_current_working_dir() or ''
    -- wezterm.log_info('cwd_uri : ' .. (cwd_uri or 'cwd_uri is nil'))
    cwd_uri = cwd_uri:gsub('file:/+', '')
    cwd_uri = cwd_uri:gsub('%%20', ' ')
    cwd_uri = cwd_uri:gsub([[C:/Users/%w+/]], '~/')
    cwd_uri = cwd_uri:gsub('/home/[^/]+/', '~/')
    cwd_uri = cwd_uri:gsub('([^/]+)', function(path_item, two)
        local output = path_item

        local MAXIMUM_PATH_LENGTH = 7
        local START_TRIM_LENGTH = 3
        local END_TRIM_LENGTH = 3
        local path_length = #path_item
        if path_length > MAXIMUM_PATH_LENGTH then
            output = string.format(
                '%s↔️%s',
                path_item:sub(1, START_TRIM_LENGTH),
                path_item:sub(path_length - END_TRIM_LENGTH, path_length)
            )
        end

        return output
    end)

    -- Replace common directories with icons
    cwd_uri = cwd_uri:gsub('~/.config', '🔧')
    cwd_uri = cwd_uri:gsub('~/AppData/Local', '🐟')
    cwd_uri = cwd_uri:gsub('~/AppData/Roaming', '🎱')
    cwd_uri = cwd_uri:gsub('C:', '©️')

    local letter_emojis = require('WeztermStimpack.icons').letter_emojis
    cwd_uri = cwd_uri:gsub('D:', function(windows_path_starter)
        return letter_emojis[windows_path_starter:sub(1, 1)]
    end)
    cwd_uri = cwd_uri:gsub('~', '🏠')

    local battery_levels = require('WeztermStimpack.icons').battery_levels

    local bat = ''
    local charge_percent_index = 1
    for _, b in ipairs(wezterm.battery_info()) do
        local charge_percent = b.state_of_charge * 100
        charge_percent_index = math.floor(charge_percent / 10)
        bat = string.format('%s %0.0f%%', battery_levels[charge_percent_index][1], charge_percent)
    end

    local leader = ''
    if window:leader_is_active() then
        leader = ' [L] '
    end

    -- TODO: can the background here be made transparent??
    local separator_icon_background = { Foreground = { Color = '#0000ff' } }
    local separator_icon = { Text = ' ፨ ' }

    local workspace_color = '#3d8fd1'

    window:set_right_status(wezterm.format({

        -- Current terminal working directory. Requires OSC7 integration.
        'ResetAttributes',
        { Foreground = { Color = workspace_color } },
        { Text = '' },
        { Background = { Color = workspace_color } },
        { Foreground = { Color = '#053c8c' } },
        { Text = cwd_uri },
        'ResetAttributes',
        { Foreground = { Color = workspace_color } },
        { Text = '' },
        'ResetAttributes',

        -- Leader symbol
        { Foreground = { Color = '#053c8c' } },
        { Background = { Color = '#c08b30' } },
        { Text = leader },
        'ResetAttributes',

        -- Separator
        separator_icon_background,
        separator_icon,
        'ResetAttributes',

        -- Active workspace
        { Foreground = { Color = workspace_color } },
        { Text = '' },
        { Background = { Color = workspace_color } },
        { Foreground = { Color = '#053c8c' } },
        { Text = window:active_workspace() },
        'ResetAttributes',
        { Foreground = { Color = workspace_color } },
        { Text = '' },
        'ResetAttributes',

        -- Battery
        separator_icon_background,
        separator_icon,
        battery_levels[charge_percent_index][2],
        { Text = bat },
        'ResetAttributes',

        -- Separator
        separator_icon_background,
        separator_icon,
        'ResetAttributes',
    }))
end)

-- TODO: not sure if this works
wezterm.on('window-config-reloaded', function(window, pane)
    window:toast_notification('wezterm', 'configuration reloaded!', nil, 4000)
end)

-- Build my default set of sessions, tabs, etc.
wezterm.on('gui-startup', function(cmd)
    local args = {}
    if cmd then
        args = cmd.args
    end

    local workspaces = {
        'CommandStation',
    }

    local wezterm_config_directory = string.format('%s/.config/wezterm', wezterm.home_dir)

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
    local project_directory_files = wezterm.read_dir(string.format('%s/projects', wezterm_config_directory))

    for i, path in ipairs(project_directory_files) do
        wezterm.log_info(string.format('File number %d = %s', i, path))

        local check_for_lua_file = path:match('(projects.*)%.lua')
        if check_for_lua_file ~= nil then
            check_for_lua_file = check_for_lua_file:gsub('[\\/]', '.')
            print('Running command: require ' .. check_for_lua_file)
            require(check_for_lua_file)
        end
    end

    require('projects.Freeus')

    mux.set_active_workspace(workspaces[1])
end)

local config = {}

config.window_close_confirmation = 'NeverPrompt'

config.font_size = 14
config.font = wezterm.font('JetBrains Mono')
-- Enable ligatures
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Use the same color scheme as neovim
config.color_scheme = 'Atelier Sulphurpool (base16)'

-- Set different default shell
config.default_prog = { 'pwsh' }

-- Tab bar config
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.show_tab_index_in_tab_bar = false
config.tab_bar_at_bottom = true
config.switch_to_last_active_tab_when_closing_tab = true

-- Give me my precious terminal space back by having no padding and no title bar
config.window_decorations = 'RESIZE'
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- Slightly translucent background
config.window_background_opacity = 0.72

config.audible_bell = 'Disabled'
config.visual_bell = {
    fade_in_function = 'EaseIn',
    fade_in_duration_ms = 150,
    fade_out_function = 'EaseOut',
    fade_out_duration_ms = 150,
}

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
}

config.colors = colors

-- Set leader key
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- Disable all default key maps
config.disable_default_key_bindings = true

-- Assign keymaps
config.keys = keymaps

-- Assign keymap tables which are special map modal mappings
config.key_tables = keymap_tables

-- TODO: add more items here to launch
config.launch_menu = {
    { args = { 'termscp' } },
    { args = { 'btop' } },
    { args = { 'pwsh', '-c', [[Get-Content $env:LOCALAPPDATA\Plover\Plover\tapey_tape.txt -Tail 50 -Wait]] } },
    { args = { 'scoop update *' } },
    { args = { 'scoop', 'cleanup', '*' } },
    {
        args = { 'nvim.exe' },
        cwd = [[C:\Users\dlomax\repos\FreeusMicronTools\fm-cli\bin\Debug\net6.0\win10-x64]],
    },
}

-- This thing is clever but it is full of issues, this script is all I need
-- & 'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1'
--
-- if wezngterm.target_triple == 'x86_64-pc-windows-msvc' then
--     table.insert(config.launch_menu, {
--         label = 'PowerShell',
--         args = { 'powershell.exe', '-NoLogo' },
--     })
--
--     -- Find installed visual studio version(s) and add their compilation
--     -- environment command prompts to the menu
--     for _, vsvers in ipairs(wezterm.glob('Microsoft Visual Studio/20*', 'C:/Program Files')) do
--         local year = vsvers:gsub('Microsoft Visual Studio/', '')
--         table.insert(config.launch_menu, {
--             label = 'x64 Native Tools VS ' .. year,
--             args = {
--                 'cmd.exe',
--                 '/k',
--                 'C:/Program Files/' .. vsvers .. '/BuildTools/VC/Auxiliary/Build/vcvars64.bat',
--             },
--         })
--     end
-- end

-- TODO: perhaps need to make this apply with windows only
config.quote_dropped_files = 'WindowsAlwaysQuoted'

config.show_update_window = false

return config
