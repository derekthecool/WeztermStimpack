-- This file is meant to provide a basic compatibility to the default tmux mappings where possible
-- Every keymap in here should be possible with any keyboard and no not require special stenography input like ./keymaps.lua does

local wezterm = require('wezterm')
local act = require('wezterm').action
local mux = wezterm.mux

return {
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

    -- Move pane to now window leader + !
    -- Rotate/move pane location leader + [ctrl + o]
    -- Select pane leader + up
    -- Select pane leader + left
    -- Select pane leader + right
    -- Select pane leader + down
    -- Move to previous pane leader + ;
    -- Search for pane leader + f
    -- Kill active pane leader + x
    -- zoom current pane leader + z
    -- swap active pane with pane above leader + {
    -- swap active pane with pane below leader + }
    -- Spread panes out evenly leader + e
    -- Toggle the marked pane leader + m
    -- Select next pane leader + o
    -- Select previous pane leader + p
    -- Display pane numbers and allow user to jump to it by typing the number leader + q
    { key = 'q', mods = 'LEADER', action = act.PaneSelect({ alphabet = '', mode = 'Activate' }) },

    -- Sessions (this is murky grounds here)
    -- choose a session from a list leader + s
    -- Rename the current session leader + $
    -- Switch to previous client leader + (
    -- Switch to next client leader + )
    -- Switch to last client leader + l
    -- Detach the current client leader + d
    -- Suspend the current client leader + [control + z]
    -- Redraw the current client leader + r

    -- Layouts
    -- Alt mappings are incompatible with my workspacer/awesomewm
    -- Set an even horizontal layout leader + [alt + 1]
    -- Set an even vertical layout leader + [alt + 2]
    -- Set an even main horizontal layout leader + [alt + 3]
    -- Set an even main vertical layout leader + [alt + 4]
    -- Set an even tiled layout leader + [alt + 5]
    -- Resize the pane up by 5 leader + [alt + up]
    -- Resize the pane down by 5 leader + [alt + down]
    -- Resize the pane left by 5 leader + [alt + left]
    -- Resize the pane right by 5 leader + [alt + right]
    -- Resize the pane up leader + [control + up]
    -- Resize the pane down leader + [control + down]
    -- Resize the pane left leader + [control + left]
    -- Resize the pane right leader + [control + right]
    --
    -- This one is very, very cool!
    -- Next layout leader + space

}
