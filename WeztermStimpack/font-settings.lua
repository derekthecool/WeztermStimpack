local wezterm = require('wezterm')

local M = {}

---@param config table
M.init = function(config)
    config.font_size = 14
    -- config.font = wezterm.font('JetBrains Mono')

    -- config.font_dirs = { 'fonts' }
    -- config.font_locator = 'ConfigDirsOnly'
    --
    -- config.font = wezterm.font_with_fallback({
    --     'Hermit',
    --     'Hack Nerd Font',
    --     'Symbols Nerd Font Mono',
    -- })

    -- Enable ligatures
    config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }
end

return M
