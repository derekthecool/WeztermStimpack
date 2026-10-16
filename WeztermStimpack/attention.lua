-- Tracks panes that rang the bell while you were not looking at them (like tmux's bell flag on a window).
-- Claude Code's hook script (~/.claude/wezterm-notifications.ps1) rings the bell when it needs input or finishes.
-- tab-format.lua asks M.attention_kind() to decide whether a tab gets a blinking highlight, and in which color.
--
-- The kind is encoded in how many bells arrive back to back (hooks cannot send anything richer into WezTerm):
--   one bell       -> 'input' (needs you, red)
--   two bells fast -> 'done'  (finished, green)
local wezterm = require('wezterm')

local M = {}

-- Two bells within this many seconds count as one 'done' signal. os.time() ticks in whole seconds, hence 1
local DOUBLE_BELL_WINDOW_SECONDS = 1

-- wezterm.GLOBAL is a proxy object, not a Lua table (next/pairs on it fail), so keep flat keys per pane
local function kind_key(pane_id)
    return 'attention_pane_' .. tostring(pane_id)
end

local function time_key(pane_id)
    return 'attention_pane_time_' .. tostring(pane_id)
end

---@return string|nil kind 'input', 'done' or nil when the pane is not flagged
local function flagged_kind(pane_id)
    return wezterm.GLOBAL[kind_key(pane_id)]
end

local function flag(pane_id, kind)
    wezterm.GLOBAL[kind_key(pane_id)] = kind
    wezterm.GLOBAL[time_key(pane_id)] = os.time()
end

local function unflag(pane_id)
    wezterm.GLOBAL[kind_key(pane_id)] = nil
    wezterm.GLOBAL[time_key(pane_id)] = nil
end

-- The user is looking at this pane right now, so there is nothing to draw attention to
local function is_being_watched(window, pane)
    local active_pane = window:active_pane()
    return window:is_focused() and active_pane ~= nil and active_pane:pane_id() == pane:pane_id()
end

local function clear_active_pane(window)
    if not window:is_focused() then
        return
    end

    local active_pane = window:active_pane()
    if active_pane and flagged_kind(active_pane:pane_id()) then
        unflag(active_pane:pane_id())
    end
end

wezterm.on('bell', function(window, pane)
    if is_being_watched(window, pane) then
        return
    end

    local pane_id = pane:pane_id()
    local last_time = wezterm.GLOBAL[time_key(pane_id)]
    local is_second_bell = flagged_kind(pane_id) ~= nil
        and last_time ~= nil
        and os.time() - last_time <= DOUBLE_BELL_WINDOW_SECONDS

    flag(pane_id, is_second_bell and 'done' or 'input')
end)

-- Switching to a flagged tab (or refocusing the window) acknowledges it
wezterm.on('update-status', clear_active_pane)
wezterm.on('window-focus-changed', clear_active_pane)

---@param tab_info table TabInformation of the tab being drawn
---@return string|nil kind 'input' (wins if panes disagree), 'done' or nil
function M.attention_kind(tab_info)
    -- Note: the `panes` argument of format-tab-title only lists the ACTIVE tab's panes, so ask the mux for this tab's
    local ok, mux_panes = pcall(function()
        return wezterm.mux.get_tab(tab_info.tab_id):panes()
    end)
    if not ok or not mux_panes then
        return flagged_kind(tab_info.active_pane.pane_id)
    end

    local found = nil
    for _, pane in ipairs(mux_panes) do
        local kind = flagged_kind(pane:pane_id())
        if kind == 'input' then
            return kind
        end
        found = found or kind
    end
    return found
end

return M
