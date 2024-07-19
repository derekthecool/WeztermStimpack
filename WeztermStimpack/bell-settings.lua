local wezterm = require('wezterm')

local M = {}

wezterm.on('bell', function(window, pane)
    -- TODO: change highlight of tab if not current like tmux
    wezterm.log_info('the bell was rung in pane ' .. pane:pane_id() .. '!')
end)

---@param config table
M.init = function(config)
    config.audible_bell = 'Disabled'
    config.visual_bell = {
        fade_in_function = 'EaseIn',
        fade_in_duration_ms = 150,
        fade_out_function = 'EaseOut',
        fade_out_duration_ms = 150,
    }
end

return M
