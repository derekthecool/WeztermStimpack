local wezterm = require('wezterm')
local colors = require('WeztermStimpack.colors')
local attention = require('WeztermStimpack.attention')

local M = {}

-- Blink colors per attention kind (see attention.lua). The dim phase always uses white text
local ATTENTION_STYLES = {
    input = { bright = '#ff3b4e', dim = '#7a1a28', text_bright = '#ffffff' }, -- needs you: red
    done = { bright = '#2ecc71', dim = '#14532d', text_bright = '#0b1020' }, -- finished: green
}

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

    -- Otherwise, use the title from the active pane in that tab
    local pane_title = tab_info.active_pane.title

    -- Debug: log what we're getting
    wezterm.log_info('pane_title: "' .. (pane_title or 'nil') .. '"')

    -- If pane title is empty, try to get the foreground process name
    if not pane_title or #pane_title == 0 then
        local success, process_name = pcall(function()
            return tab_info.active_pane:get_foreground_process_name()
        end)
        wezterm.log_info('process_name: "' .. (process_name or 'nil') .. '"')
        if success and process_name and #process_name > 0 then
            return process_name
        end
    end

    return pane_title or ''
end

-- Allow custom tab rename
-- Early versions did not support this, yay now we have it!
-- https://wezfurlong.org/wezterm/config/lua/keyassignment/PromptInputLine.html?h=
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local left_icon = ''
    local right_icon = ''

    -- Reserve room for the caps and trailing space so the title never gets hard-clipped
    -- by wezterm (which cuts mid-word and drops the right cap).
    -- A zoomed pane (leader + z) gets a [Z] prefix so it is obvious other panes are hidden
    local zoom_marker = tab.active_pane.is_zoomed and '[Z] ' or ''
    local reserved = wezterm.column_width(left_icon) + wezterm.column_width(right_icon) + 1
    local available = math.max(max_width - reserved - wezterm.column_width(zoom_marker), 2)

    -- Strip any leading path / .exe so process names stay short, then truncate with an ellipsis
    local title = tab_title(tab):gsub('^.*[\\/]', ''):gsub('%.exe$', '')
    local pane_title = title
    if wezterm.column_width(title) > available then
        pane_title = wezterm.truncate_right(title, available - 1) .. '…'
    end

    local full_background = colors.tab_bar.background

    -- The caps and the title share one fill color; the color shows which state the tab is in
    local edge_color = '#2f3b72' -- inactive
    local text_color = '#c0c0c0'
    local zoom_color = '#00FF00' -- Same green as the battery at full charge
    local italic = false
    if tab.is_active then
        edge_color = '#7a82e0' -- blue shifted toward purple
        text_color = '#0b1020'
        zoom_color = '#0a4d12' -- bright green is unreadable on the blue fill
        italic = true
    elseif hover then
        edge_color = '#8a63c7'
        text_color = '#ffffff'
    end

    -- A pane in this tab rang the bell while unseen (e.g. Claude Code wants input or finished): blink once per second.
    -- Overrides the active/hover colors. The tab bar repaints on update-status (status_update_interval).
    local attention_style = ATTENTION_STYLES[attention.attention_kind(tab)]
    if attention_style then
        local bright_phase = os.time() % 2 == 0
        edge_color = bright_phase and attention_style.bright or attention_style.dim
        text_color = bright_phase and attention_style.text_bright or '#ffffff'
        zoom_color = text_color
        italic = false
    end

    return {
        { Background = { Color = full_background } },
        { Foreground = { Color = edge_color } },
        { Text = left_icon },
        { Background = { Color = edge_color } },
        { Foreground = { Color = zoom_color } },
        { Text = zoom_marker },
        { Foreground = { Color = text_color } },
        { Attribute = { Italic = italic } },
        { Text = pane_title },
        'ResetAttributes',
        { Background = { Color = full_background } },
        { Foreground = { Color = edge_color } },
        { Text = right_icon },
        { Text = ' ' },
    }
end)

M.init = function(config)
    -- Tab bar config
    config.status_update_interval = 1000 -- also drives the 1s blink of attention tabs
    config.use_fancy_tab_bar = false
    config.show_new_tab_button_in_tab_bar = false
    config.show_tab_index_in_tab_bar = false
    config.tab_bar_at_bottom = true
    config.switch_to_last_active_tab_when_closing_tab = true
end

return M
