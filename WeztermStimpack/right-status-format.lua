local wezterm = require('wezterm')
local attention = require('WeztermStimpack.attention')

-- Triangle caps around each workspace name (nerd font powerline-extra glyphs)
local LEFT_CAP = '\u{e0ba}'
local RIGHT_CAP = '\u{e0b8}'

-- Same fill and text colors as the active and inactive tabs in tab-format.lua
local ACTIVE_WORKSPACE = { fill = '#7a82e0', text = '#0b1020' }
local INACTIVE_WORKSPACE = { fill = '#2f3b72', text = '#c0c0c0' }

---@param name string
---@param fill string
---@param text string
---@return table format items for wezterm.format
local function workspace_chip(name, fill, text)
    return {
        { Foreground = { Color = fill } },
        { Text = LEFT_CAP },
        { Background = { Color = fill } },
        { Foreground = { Color = text } },
        { Text = name },
        'ResetAttributes',
        { Foreground = { Color = fill } },
        { Text = RIGHT_CAP },
        'ResetAttributes',
        { Text = ' ' },
    }
end

wezterm.on('update-right-status', function(window, pane)
    local battery_levels = require('WeztermStimpack.icons').battery_levels

    local bat = ''
    local charge_percent_index = 1
    for _, b in ipairs(wezterm.battery_info()) do
        local charge_percent = b.state_of_charge * 100
        charge_percent_index = math.max(1, math.floor(charge_percent / 10))
        -- Usually plugged in: stay quiet at (rounded) 100%
        if math.floor(charge_percent + 0.5) < 100 then
            bat = string.format('%s %0.0f%%', battery_levels[charge_percent_index][1], charge_percent)
        end
    end

    local leader = ''
    if window:leader_is_active() then
        leader = ' [L] '
    end

    local items = {
        -- Leader symbol
        'ResetAttributes',
        { Foreground = { Color = '#053c8c' } },
        { Background = { Color = '#c08b30' } },
        { Text = leader },
        'ResetAttributes',
    }

    -- Every workspace by its full name. The active one is highlighted, and a workspace with unseen Claude
    -- activity blinks red (needs input) or green (finished), see attention.lua
    local active_workspace = window:active_workspace()
    local flagged_workspaces = attention.workspace_kinds()
    for _, name in ipairs(wezterm.mux.get_workspace_names()) do
        local style = (name == active_workspace) and ACTIVE_WORKSPACE or INACTIVE_WORKSPACE
        local blink_fill, blink_text = attention.blink_colors(flagged_workspaces[name])
        local chip = workspace_chip(name, blink_fill or style.fill, blink_text or style.text)
        for _, item in ipairs(chip) do
            table.insert(items, item)
        end
    end

    -- Battery (empty at 100% or when there is no battery)
    if bat ~= '' then
        table.insert(items, battery_levels[charge_percent_index][2])
        table.insert(items, { Text = bat })
        table.insert(items, 'ResetAttributes')
    end

    -- Invisible tick: wezterm only re-runs format-tab-title when the bar content changes, so without this a
    -- background tab flagged by attention.lua would not be redrawn (blinking) until something else changed.
    table.insert(items, { Foreground = { Color = (os.time() % 2 == 0) and '#010101' or '#020202' } })
    table.insert(items, { Text = ' ' })
    table.insert(items, 'ResetAttributes')

    window:set_right_status(wezterm.format(items))
end)

wezterm.on('window-config-reloaded', function(window, pane)
    window:toast_notification('wezterm', 'config reloaded', nil, 4000)
end)
