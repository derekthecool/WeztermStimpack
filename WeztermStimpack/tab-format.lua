local wezterm = require('wezterm')
local colors = require('WeztermStimpack.colors')

local M = {}

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

    local full_background = colors.tab_bar.background
    local background = colors.tab_bar.inactive_tab.bg_color
    local foreground = background

    if tab.is_active then
        background = full_background
    elseif hover then
        background = colors.tab_bar.inactive_tab_hover.bg_color
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

M.init = function(config)
    -- Tab bar config
    config.use_fancy_tab_bar = false
    config.show_new_tab_button_in_tab_bar = false
    config.show_tab_index_in_tab_bar = false
    config.tab_bar_at_bottom = true
    config.switch_to_last_active_tab_when_closing_tab = true
end

return M
