local wezterm = require('wezterm')

wezterm.on('update-right-status', function(window, pane)
    -- As of 20240127-113634-bbcac864 this function returns a url object and not a string
    local cwd_uri = pane:get_current_working_dir()

    if cwd_uri ~= nil then
        wezterm.log_info(string.format('Initial value for cwd_url: %s', cwd_uri))
        cwd_uri = cwd_uri.path
        cwd_uri = cwd_uri:gsub('file:/+', '')
        cwd_uri = cwd_uri:gsub('%%20', ' ')
        cwd_uri = cwd_uri:gsub([[/C:/Users/%w+/]], '~/')
        cwd_uri = cwd_uri:gsub('/home/[^/]+/', '~/')
        cwd_uri = cwd_uri:gsub('^/([A-Z]:)', '%1')
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
    else
        wezterm.log_info('cwd_uri from pane:get_current_working_dir() returned nil')
        cwd_uri = ''
    end

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
        { Text = cwd_uri or 'COW' },
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
