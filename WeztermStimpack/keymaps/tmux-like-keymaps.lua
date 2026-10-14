-- This file is meant to provide a basic compatibility to the default tmux mappings where possible
-- Every keymap in here should be possible with any keyboard and no not require special stenography input like ./keymaps.lua does

local wezterm = require('wezterm')
local act = require('wezterm').action
local mux = wezterm.mux

return {
    -- Move between wezterm workspaces (tmux sessions)
    { key = ')', mods = 'SHIFT|LEADER', action = act.SwitchWorkspaceRelative(1) },
    { key = '(', mods = 'SHIFT|LEADER', action = act.SwitchWorkspaceRelative(-1) },

    -- Workspace select
    {
        key = 's',
        mods = 'LEADER',
        action = act.ShowLauncherArgs({ flags = 'WORKSPACES|FUZZY', title = 'Switch Workspace' }),
    },
    {
        key = 'S',
        mods = 'SHIFT|LEADER',
        action = act.ShowLauncherArgs({
            flags = 'DOMAINS|FUZZY|TABS|LAUNCH_MENU_ITEMS|KEY_ASSIGNMENTS|WORKSPACES|COMMANDS',
            title = 'Fuzzy Chooser',
        }),
    },

    -- Move between wezterm tabs (tmux windows)
    { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
    { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
    { key = '0', mods = 'LEADER', action = act.ActivateTab(0) },
    { key = '1', mods = 'LEADER', action = act.ActivateTab(1) },
    { key = '2', mods = 'LEADER', action = act.ActivateTab(2) },
    { key = '3', mods = 'LEADER', action = act.ActivateTab(3) },
    { key = '4', mods = 'LEADER', action = act.ActivateTab(4) },
    { key = '5', mods = 'LEADER', action = act.ActivateTab(5) },
    { key = '6', mods = 'LEADER', action = act.ActivateTab(6) },
    { key = '7', mods = 'LEADER', action = act.ActivateTab(7) },
    { key = '8', mods = 'LEADER', action = act.ActivateTab(8) },
    { key = '9', mods = 'LEADER', action = act.ActivateTab(9) },
    { key = 'c', mods = 'LEADER', action = act.SpawnTab('CurrentPaneDomain') },

    -- Close current tab (tmux window)
    { key = '&', mods = 'LEADER', action = act.CloseCurrentTab({ confirm = true }) },

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

    -- Panes
    -- tmux splits: % is left/right, " is top/bottom (your | and - in keymaps.lua do the same)
    { key = '%', mods = 'SHIFT|LEADER', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
    { key = '"', mods = 'SHIFT|LEADER', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },

    -- Select pane by direction (leader + arrows)
    { key = 'UpArrow', mods = 'LEADER', action = act.ActivatePaneDirection('Up') },
    { key = 'DownArrow', mods = 'LEADER', action = act.ActivatePaneDirection('Down') },
    { key = 'LeftArrow', mods = 'LEADER', action = act.ActivatePaneDirection('Left') },
    { key = 'RightArrow', mods = 'LEADER', action = act.ActivatePaneDirection('Right') },

    -- Next / previous / last pane
    { key = 'o', mods = 'LEADER', action = act.ActivatePaneDirection('Next') },
    -- wezterm has no "last used pane", Prev is the closest equivalent
    { key = ';', mods = 'LEADER', action = act.ActivatePaneDirection('Prev') },

    -- Zoom current pane
    { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

    -- Move pane to a new tab (tmux: break-pane)
    {
        key = '!',
        mods = 'SHIFT|LEADER',
        action = wezterm.action_callback(function(window, pane)
            pane:move_to_new_tab()
        end),
    },

    -- Rotate panes (tmux: leader + { / } swaps with prev/next pane, leader + ctrl+o rotates)
    { key = '{', mods = 'SHIFT|LEADER', action = act.RotatePanes('CounterClockwise') },
    { key = '}', mods = 'SHIFT|LEADER', action = act.RotatePanes('Clockwise') },
    { key = 'o', mods = 'LEADER|CTRL', action = act.RotatePanes('Clockwise') },

    -- Display pane numbers and allow user to jump to it by typing the number
    { key = 'q', mods = 'LEADER', action = act.PaneSelect({ alphabet = '', mode = 'Activate' }) },

    -- Resize panes: leader + ctrl + arrow resizes by 1, as in tmux
    { key = 'UpArrow', mods = 'LEADER|CTRL', action = act.AdjustPaneSize({ 'Up', 1 }) },
    { key = 'DownArrow', mods = 'LEADER|CTRL', action = act.AdjustPaneSize({ 'Down', 1 }) },
    { key = 'LeftArrow', mods = 'LEADER|CTRL', action = act.AdjustPaneSize({ 'Left', 1 }) },
    { key = 'RightArrow', mods = 'LEADER|CTRL', action = act.AdjustPaneSize({ 'Right', 1 }) },
    -- tmux uses leader + alt + arrow for 5 cells, but alt is taken by workspacer/awesomewm: use shift instead
    { key = 'UpArrow', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize({ 'Up', 5 }) },
    { key = 'DownArrow', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize({ 'Down', 5 }) },
    { key = 'LeftArrow', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize({ 'Left', 5 }) },
    { key = 'RightArrow', mods = 'LEADER|SHIFT', action = act.AdjustPaneSize({ 'Right', 5 }) },

    -- Not mapped, already used in keymaps.lua: x (kill pane), f (find), l (last window), r (redraw)
    -- Not mapped, no wezterm equivalent: m (mark pane), e (spread evenly)

    -- Copy mode / paste buffer
    { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
    { key = 'PageUp', mods = 'LEADER', action = act.Multiple({ act.ActivateCopyMode, act.CopyMode('PageUp') }) },
    { key = ']', mods = 'LEADER', action = act.PasteFrom('Clipboard') },

    -- Command prompt / help / choosers
    { key = ':', mods = 'SHIFT|LEADER', action = act.ActivateCommandPalette },
    {
        key = '?',
        mods = 'SHIFT|LEADER',
        action = act.ShowLauncherArgs({ flags = 'KEY_ASSIGNMENTS|FUZZY', title = 'Key Bindings' }),
    },
    -- Choose window (tab) from a list; lowercase w is already taken by a pwsh launcher
    { key = 'W', mods = 'SHIFT|LEADER', action = act.ShowLauncherArgs({ flags = 'TABS|FUZZY', title = 'Switch Tab' }) },
    -- Prompt for a tab index to jump to
    {
        key = '\'',
        mods = 'LEADER',
        action = act.PromptInputLine({
            description = 'Enter tab index (0 based)',
            action = wezterm.action_callback(function(window, pane, line)
                local index = line and tonumber(line)
                if index then
                    window:perform_action(act.ActivateTab(index), pane)
                end
            end),
        }),
    },

    -- Sessions (wezterm workspaces / domains). s, S, ( and ) are mapped above
    {
        key = '$',
        mods = 'SHIFT|LEADER',
        action = act.PromptInputLine({
            description = 'Enter new name for workspace',
            action = wezterm.action_callback(function(window, pane, line)
                if line and #line > 0 then
                    mux.rename_workspace(mux.get_active_workspace(), line)
                end
            end),
        }),
    },
    -- Detach from the current domain (only meaningful for multiplexer domains)
    { key = 'd', mods = 'LEADER', action = act.DetachDomain('CurrentPaneDomain') },

    -- Layouts
    -- wezterm has no preset layouts (even-horizontal, tiled, next-layout on leader + space), so none are mapped.
    -- Alt mappings are incompatible with my workspacer/awesomewm
}
