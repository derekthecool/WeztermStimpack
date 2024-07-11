-- This file is meant to provide a basic compatibility to the default tmux mappings where possible
-- Every keymap in here should be possible with any keyboard and no not require special stenography input like ./keymaps.lua does

local wezterm = require('wezterm')
local act = require('wezterm').action
local mux = wezterm.mux

return {
    -- Move between tabs
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
}
