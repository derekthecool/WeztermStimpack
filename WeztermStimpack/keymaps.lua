local wezterm = require('wezterm')
local act = require('wezterm').action
local mux = wezterm.mux

Global_KeepRunningLoopedCommand = false

local char_to_hex = function(c)
    return string.format('%%%02X', string.byte(c))
end

local function urlencode(url)
    if url == nil then
        return
    end
    url = url:gsub('\n', '\r\n')
    url = url:gsub('([^%w ])', char_to_hex)
    url = url:gsub(' ', '+')
    return url
end

local hex_to_char = function(x)
    return string.char(tonumber(x, 16))
end

local urldecode = function(url)
    if url == nil then
        return
    end
    url = url:gsub('+', ' ')
    url = url:gsub('%%(%x%x)', hex_to_char)
    return url
end

return {
    -- When using steno, shift is not needed. It just seems to be implied because normal keyboard needs a shift
    { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    { key = '-', mods = 'LEADER',       action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
    -- -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
    { key = 'a', mods = 'LEADER|CTRL',  action = act.SendString('\x01') },

    -- Launch specific programs
    {
        key = 't',
        mods = 'LEADER',
        action = act.SplitHorizontal({ domain = 'CurrentPaneDomain', args = { 'ntop' } }),
    },
    {
        key = 'v',
        mods = 'LEADER',
        action = act.SpawnCommandInNewTab({ domain = 'CurrentPaneDomain', args = { 'ntop' } }),
    },
    {
        key = 'w',
        mods = 'LEADER',
        action = act.SpawnCommandInNewTab({ domain = 'CurrentPaneDomain', args = { 'pwsh -c ls' } }),
    },

    {
        key = 'r',
        mods = 'LEADER',
        action = act.PromptInputLine({
            description = 'Enter command to send on 7 minute interval',
            action = wezterm.action_callback(function(window, pane, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote
                if line then
                    -- window:active_tab():set_title(line)
                    wezterm.log_info(string.format('Enabling autocommand running with command: %s', line))
                    Global_KeepRunningLoopedCommand = true
                    while Global_KeepRunningLoopedCommand do
                        pane:send_text(line)
                        local sleep_seconds = 360
                        wezterm.sleep_ms(sleep_seconds * 1000)
                    end
                end
            end),
        }),
    },

    {
        key = 'R',
        mods = 'LEADER',
        action = wezterm.action_callback(function(window, pane, line)
            Global_KeepRunningLoopedCommand = false
            wezterm.log_info(string.format('Disabling autocommand running'))
        end),
    },

    {
        key = ',',
        mods = 'LEADER',
        action = act.PromptInputLine({
            description = 'Enter new name for tab',
            action = wezterm.action_callback(function(window, pane, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        }),
    },
    {
        key = '/',
        mods = 'LEADER',
        action = act.PromptInputLine({
            description = 'Brave search query',
            action = wezterm.action_callback(function(window, pane, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote

                wezterm.log_info(string.format('Hello from brave search query with %s as input', line))
                wezterm.log_info(window, pane, line)
                wezterm.log_info(window:mux_window())

                if line then
                    local command_tab, command_pane, command_window = window:mux_window():spawn_tab({
                        cwd = os.getenv('LOCALAPPDATA') .. [[\nvim]],
                    })

                    wezterm.log_info(command_tab)
                    wezterm.log_info(command_pane)
                    wezterm.log_info(command_window)

                    command_tab:set_title('carbonyl search')
                    command_pane:send_text(
                        string.format(
                            'podman run --rm -ti fathyb/carbonyl https://search.brave.com/search?q=%s\r\n',
                            urlencode(line)
                        )
                    )
                end
            end),
        }),
    },

    -- { key = 'T', mods = 'CTRL', action = act.SpawnTab('CurrentPaneDomain') },

    -- { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },

    --[[
    Command launcher
    https://wezfurlong.org/wezterm/config/lua/keyassignment/ShowLauncherArgs.html

    * "FUZZY" - activate in fuzzy-only mode. By default the launcher will allow
      using the number keys to select from the first few items, as well as vi
      movement keys to select items. Pressing / will enter fuzzy filtering mode,
      allowing you to type a search term and reduce the set of matches. When you
      use the "FUZZY" flag, the launcher activates directly in fuzzy filtering mode.
    * "TABS" - include the list of tabs from the current window
    * "LAUNCH_MENU_ITEMS" - include the launch_menu items
    * "DOMAINS" - include multiplexing domains
    * "KEY_ASSIGNMENTS" - include items taken from your key assignments
    * "WORKSPACES" - include workspaces
    * "COMMANDS" - include a number of default commands (Since: 20220408-101518-b908e2dd)
    ]]

    -- Open with all launch options, this is powerful but over the top sometimes
    { key = '°', action = act.ShowLauncher },
    -- Open with just item set from launch_menu
    { key = '÷', action = act.ShowLauncherArgs({ flags = 'LAUNCH_MENU_ITEMS|FUZZY' }) },
    { key = '»', action = act.ActivateTabRelative(1) },
    { key = '«', action = act.ActivateTabRelative(-1) },

    -- Use steno key group SKWH[EU]G to activate these commands
    -- TODO: create non-steno mappings as well
    { key = '±', action = act.ShowLauncherArgs({ flags = 'WORKSPACES' }) },
    { key = '¶', action = act.SwitchWorkspaceRelative(1) },
    { key = '∑', action = act.SwitchWorkspaceRelative(-1) },
    {
        key = '1',
        mods = 'CTRL|SHIFT',
        action = act.SwitchToWorkspace({
            name = 'CommandStation',
        }),
    },

    {
        mods = 'CTRL|SHIFT',
        key = 'i',
        action = wezterm.action_callback(function(win, pane)
            wezterm.log_info('Hello from callback!')
            wezterm.log_info('WindowID:', win:window_id(), 'PaneID:', pane:pane_id())
        end),
    },

    {
        key = 'a',
        mods = 'CTRL|SHIFT',
        action = act.SwitchToWorkspace({
            name = 'CommandStation',
        }),
    },
    {
        key = 'o',
        mods = 'CTRL|SHIFT',
        action = act.SwitchToWorkspace({
            name = 'FreeusDev',
        }),
    },
    {
        key = 'e',
        mods = 'CTRL|SHIFT',
        action = act.SwitchToWorkspace({
            name = 'Micron',
        }),
    },

    -- Function key mappings
    {
        key = 'F3',
        mods = 'NONE',
        action = act.ActivateCommandPalette,
    },

    { key = 'j', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
    { key = 'k', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },
    { key = 'h', mods = 'CTRL|ALT',   action = act.ActivatePaneDirection('Left') },
    { key = 'l', mods = 'CTRL|ALT',   action = act.ActivatePaneDirection('Right') },
    { key = 'j', mods = 'CTRL|ALT',   action = act.ActivatePaneDirection('Down') },
    { key = 'k', mods = 'CTRL|ALT',   action = act.ActivatePaneDirection('Up') },
    {
        key = 'h',
        mods = 'LEADER',
        action = act.ActivatePaneDirection('Left'),
    },
    {
        key = 'l',
        mods = 'LEADER',
        action = act.ActivatePaneDirection('Right'),
    },
    {
        key = 'j',
        mods = 'LEADER',
        action = act.ActivatePaneDirection('Down'),
    },
    {
        key = 'k',
        mods = 'LEADER',
        action = act.ActivatePaneDirection('Up'),
    },

    {
        key = 'F9',
        mods = 'CTRL|SHIFT',
        action = act.ShowTabNavigator,
    },

    {
        key = 'a',
        mods = 'LEADER',
        action = act.AttachDomain('CommandStation'),
    },
    {
        key = 'x',
        mods = 'LEADER',
        action = act.CloseCurrentPane({ confirm = false }),
    },

    -- -- { key = 'F10', mods = 'NONE', action = wezterm.action.AttachDomain('device.MQTTBroker') },
    -- -- { key = 'F10', mods = 'NONE', action = wezterm.action.AttachDomain('homeserver.Proxmox1') },
    -- -- { key = 'F10', mods = 'NONE', action = wezterm.action.AttachDomain('Development') },
    -- { key = 'F2', mods = 'NONE', action = act.ScrollToPrompt(-1) },
    -- { key = 'F3', mods = 'NONE', action = act.ScrollToPrompt(1) },
    -- { key = 'F4', mods = 'NONE', action = act.SelectTextAtMouseCursor('SemanticZone') },
    -- -- { key = 'F4', mods = 'NONE', action = act.ScrollToPrompt(-1) },

    -- Default key maps
    {
        key = 'X',
        mods = 'CTRL',
        action = act.ActivateCopyMode,
    },
    {
        key = 'X',
        mods = 'SHIFT|CTRL',
        action = act.ActivateCopyMode,
    },
    {
        key = 'x',
        mods = 'SHIFT|CTRL',
        action = act.ActivateCopyMode,
    },
    {
        key = 'DownArrow',
        mods = 'SHIFT|CTRL',
        action = act.ActivatePaneDirection('Down'),
    },
    {
        key = 'LeftArrow',
        mods = 'SHIFT|CTRL',
        action = act.ActivatePaneDirection('Left'),
    },
    {
        key = 'RightArrow',
        mods = 'SHIFT|CTRL',
        action = act.ActivatePaneDirection('Right'),
    },
    {
        key = 'UpArrow',
        mods = 'SHIFT|CTRL',
        action = act.ActivatePaneDirection('Up'),
    },
    {
        key = '(',
        mods = 'CTRL',
        action = act.ActivateTab(-1),
    },
    {
        key = '(',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(-1),
    },
    {
        key = '9',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(-1),
    },
    {
        key = '9',
        mods = 'SUPER',
        action = act.ActivateTab(-1),
    },
    {
        key = '!',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(0),
    },
    {
        key = '!',
        mods = 'CTRL',
        action = act.ActivateTab(0),
    },
    {
        key = '1',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(0),
    },
    {
        key = '1',
        mods = 'SUPER',
        action = act.ActivateTab(0),
    },
    {
        key = '2',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(1),
    },
    {
        key = '2',
        mods = 'SUPER',
        action = act.ActivateTab(1),
    },
    {
        key = '@',
        mods = 'CTRL',
        action = act.ActivateTab(1),
    },
    {
        key = '@',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(1),
    },
    {
        key = '#',
        mods = 'CTRL',
        action = act.ActivateTab(2),
    },
    {
        key = '#',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(2),
    },
    {
        key = '3',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(2),
    },
    {
        key = '3',
        mods = 'SUPER',
        action = act.ActivateTab(2),
    },
    {
        key = '$',
        mods = 'CTRL',
        action = act.ActivateTab(3),
    },
    {
        key = '$',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(3),
    },
    {
        key = '4',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(3),
    },
    {
        key = '4',
        mods = 'SUPER',
        action = act.ActivateTab(3),
    },
    {
        key = '%',
        mods = 'CTRL',
        action = act.ActivateTab(4),
    },
    {
        key = '%',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(4),
    },
    {
        key = '5',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(4),
    },
    {
        key = '5',
        mods = 'SUPER',
        action = act.ActivateTab(4),
    },
    {
        key = '6',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(5),
    },
    {
        key = '6',
        mods = 'SUPER',
        action = act.ActivateTab(5),
    },
    {
        key = '^',
        mods = 'CTRL',
        action = act.ActivateTab(5),
    },
    {
        key = '^',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(5),
    },
    {
        key = '&',
        mods = 'CTRL',
        action = act.ActivateTab(6),
    },
    {
        key = '&',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(6),
    },
    {
        key = '7',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(6),
    },
    {
        key = '7',
        mods = 'SUPER',
        action = act.ActivateTab(6),
    },
    {
        key = '*',
        mods = 'CTRL',
        action = act.ActivateTab(7),
    },
    {
        key = '*',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(7),
    },
    {
        key = '8',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTab(7),
    },
    {
        key = '8',
        mods = 'SUPER',
        action = act.ActivateTab(7),
    },
    {
        key = 'Tab',
        mods = 'SHIFT|CTRL',
        action = act.ActivateTabRelative(-1),
    },
    {
        key = '[',
        mods = 'SHIFT|SUPER',
        action = act.ActivateTabRelative(-1),
    },
    {
        key = '{',
        mods = 'SUPER',
        action = act.ActivateTabRelative(-1),
    },
    {
        key = '{',
        mods = 'SHIFT|SUPER',
        action = act.ActivateTabRelative(-1),
    },
    {
        key = 'PageUp',
        mods = 'CTRL',
        action = act.ActivateTabRelative(-1),
    },
    {
        key = 'Tab',
        mods = 'CTRL',
        action = act.ActivateTabRelative(1),
    },
    {
        key = ']',
        mods = 'SHIFT|SUPER',
        action = act.ActivateTabRelative(1),
    },
    {
        key = '}',
        mods = 'SUPER',
        action = act.ActivateTabRelative(1),
    },
    {
        key = '}',
        mods = 'SHIFT|SUPER',
        action = act.ActivateTabRelative(1),
    },
    {
        key = 'PageDown',
        mods = 'CTRL',
        action = act.ActivateTabRelative(1),
    },
    {
        key = 'DownArrow',
        mods = 'SHIFT|ALT|CTRL',
        action = act.AdjustPaneSize({ 'Down', 1 }),
    },
    {
        key = 'LeftArrow',
        mods = 'SHIFT|ALT|CTRL',
        action = act.AdjustPaneSize({ 'Left', 1 }),
    },
    {
        key = 'RightArrow',
        mods = 'SHIFT|ALT|CTRL',
        action = act.AdjustPaneSize({ 'Right', 1 }),
    },
    {
        key = 'UpArrow',
        mods = 'SHIFT|ALT|CTRL',
        action = act.AdjustPaneSize({ 'Up', 1 }),
    },
    {
        key = 'U',
        mods = 'CTRL',
        action = act.CharSelect({ copy_on_select = true, copy_to = 'ClipboardAndPrimarySelection' }),
    },
    {
        key = 'U',
        mods = 'SHIFT|CTRL',
        action = act.CharSelect({ copy_on_select = true, copy_to = 'ClipboardAndPrimarySelection' }),
    },
    {
        key = 'u',
        mods = 'SHIFT|CTRL',
        action = act.CharSelect({ copy_on_select = true, copy_to = 'ClipboardAndPrimarySelection' }),
    },
    { key = 'K',          mods = 'CTRL',           action = act.ClearScrollback('ScrollbackOnly') },
    { key = 'K',          mods = 'SHIFT|CTRL',     action = act.ClearScrollback('ScrollbackOnly') },
    { key = 'k',          mods = 'SHIFT|CTRL',     action = act.ClearScrollback('ScrollbackOnly') },
    { key = 'k',          mods = 'SUPER',          action = act.ClearScrollback('ScrollbackOnly') },
    { key = 'W',          mods = 'CTRL',           action = act.CloseCurrentTab({ confirm = true }) },
    { key = 'W',          mods = 'SHIFT|CTRL',     action = act.CloseCurrentTab({ confirm = true }) },
    { key = 'w',          mods = 'SHIFT|CTRL',     action = act.CloseCurrentTab({ confirm = true }) },
    { key = 'w',          mods = 'SUPER',          action = act.CloseCurrentTab({ confirm = true }) },
    { key = 'C',          mods = 'CTRL',           action = act.CopyTo('Clipboard') },
    { key = 'C',          mods = 'SHIFT|CTRL',     action = act.CopyTo('Clipboard') },
    { key = 'c',          mods = 'SHIFT|CTRL',     action = act.CopyTo('Clipboard') },
    { key = 'c',          mods = 'SUPER',          action = act.CopyTo('Clipboard') },
    { key = 'Copy',       mods = 'NONE',           action = act.CopyTo('Clipboard') },
    { key = 'Insert',     mods = 'CTRL',           action = act.CopyTo('PrimarySelection') },
    { key = '-',          mods = 'CTRL',           action = act.DecreaseFontSize },
    { key = '-',          mods = 'SHIFT|CTRL',     action = act.DecreaseFontSize },
    { key = '-',          mods = 'SUPER',          action = act.DecreaseFontSize },
    { key = '_',          mods = 'CTRL',           action = act.DecreaseFontSize },
    { key = '_',          mods = 'SHIFT|CTRL',     action = act.DecreaseFontSize },
    { key = 'M',          mods = 'CTRL',           action = act.Hide },
    { key = 'M',          mods = 'SHIFT|CTRL',     action = act.Hide },
    { key = 'm',          mods = 'SHIFT|CTRL',     action = act.Hide },
    { key = 'm',          mods = 'SUPER',          action = act.Hide },
    { key = '+',          mods = 'CTRL',           action = act.IncreaseFontSize },
    { key = '+',          mods = 'SHIFT|CTRL',     action = act.IncreaseFontSize },
    { key = '=',          mods = 'CTRL',           action = act.IncreaseFontSize },
    { key = '=',          mods = 'SHIFT|CTRL',     action = act.IncreaseFontSize },
    { key = '=',          mods = 'SUPER',          action = act.IncreaseFontSize },
    { key = 'PageUp',     mods = 'SHIFT|CTRL',     action = act.MoveTabRelative(-1) },
    { key = 'PageDown',   mods = 'SHIFT|CTRL',     action = act.MoveTabRelative(1) },
    -- { key = 'P', mods = 'CTRL', action = act.PaneSelect({ alphabet = '', mode = 'Activate' }) },
    { key = 'P',          mods = 'SHIFT|CTRL',     action = act.PaneSelect({ alphabet = '', mode = 'Activate' }) },
    { key = 'p',          mods = 'SHIFT|CTRL',     action = act.PaneSelect({ alphabet = '', mode = 'Activate' }) },
    { key = 'V',          mods = 'CTRL',           action = act.PasteFrom('Clipboard') },
    { key = 'V',          mods = 'SHIFT|CTRL',     action = act.PasteFrom('Clipboard') },
    { key = 'v',          mods = 'SHIFT|CTRL',     action = act.PasteFrom('Clipboard') },
    { key = 'v',          mods = 'SUPER',          action = act.PasteFrom('Clipboard') },
    { key = 'Paste',      mods = 'NONE',           action = act.PasteFrom('Clipboard') },
    { key = 'Insert',     mods = 'SHIFT',          action = act.PasteFrom('PrimarySelection') },
    { key = 'phys:Space', mods = 'SHIFT|CTRL',     action = act.QuickSelect },
    { key = 'R',          mods = 'SHIFT|CTRL',     action = act.ReloadConfiguration },
    { key = 'r',          mods = 'SHIFT|CTRL',     action = act.ReloadConfiguration },
    { key = ')',          mods = 'CTRL',           action = act.ResetFontSize },
    { key = ')',          mods = 'SHIFT|CTRL',     action = act.ResetFontSize },
    { key = '0',          mods = 'CTRL',           action = act.ResetFontSize },
    { key = '0',          mods = 'SHIFT|CTRL',     action = act.ResetFontSize },
    { key = '0',          mods = 'SUPER',          action = act.ResetFontSize },
    { key = 'PageUp',     mods = 'SHIFT',          action = act.ScrollByPage(-1) },
    { key = 'PageDown',   mods = 'SHIFT',          action = act.ScrollByPage(1) },
    { key = 'F',          mods = 'CTRL',           action = act.Search('CurrentSelectionOrEmptyString') },
    { key = 'F',          mods = 'SHIFT|CTRL',     action = act.Search('CurrentSelectionOrEmptyString') },
    { key = 'f',          mods = 'SHIFT|CTRL',     action = act.Search('CurrentSelectionOrEmptyString') },
    { key = 'f',          mods = 'SUPER',          action = act.Search('CurrentSelectionOrEmptyString') },
    { key = 'L',          mods = 'CTRL',           action = act.ShowDebugOverlay },
    { key = 'L',          mods = 'SHIFT|CTRL',     action = act.ShowDebugOverlay },
    { key = 'l',          mods = 'SHIFT|CTRL',     action = act.ShowDebugOverlay },
    { key = 'T',          mods = 'CTRL',           action = act.SpawnTab('CurrentPaneDomain') },
    { key = 'T',          mods = 'SHIFT|CTRL',     action = act.SpawnTab('CurrentPaneDomain') },
    { key = 't',          mods = 'SHIFT|CTRL',     action = act.SpawnTab('CurrentPaneDomain') },
    { key = 't',          mods = 'SUPER',          action = act.SpawnTab('CurrentPaneDomain') },
    { key = 'N',          mods = 'CTRL',           action = act.SpawnWindow },
    { key = 'N',          mods = 'SHIFT|CTRL',     action = act.SpawnWindow },
    { key = 'n',          mods = 'SHIFT|CTRL',     action = act.SpawnWindow },
    { key = 'n',          mods = 'SUPER',          action = act.SpawnWindow },
    { key = '%',          mods = 'ALT|CTRL',       action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    { key = '%',          mods = 'SHIFT|ALT|CTRL', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    { key = '5',          mods = 'SHIFT|ALT|CTRL', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    { key = '"',          mods = 'ALT|CTRL',       action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
    { key = '"',          mods = 'SHIFT|ALT|CTRL', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
    { key = '\'',         mods = 'SHIFT|ALT|CTRL', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
    { key = 'Enter',      mods = 'ALT',            action = act.ToggleFullScreen },
    { key = 'Z',          mods = 'CTRL',           action = act.TogglePaneZoomState },
    { key = 'Z',          mods = 'SHIFT|CTRL',     action = act.TogglePaneZoomState },
    { key = 'z',          mods = 'SHIFT|CTRL',     action = act.TogglePaneZoomState },
}
