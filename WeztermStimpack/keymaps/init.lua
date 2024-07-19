local wezterm = require('wezterm')

local M = {}

M.collect_keymap_files = function()
    local keymap_dir = string.format('%s/WeztermStimpack/keymaps', wezterm.config_dir)
    wezterm.log_info(string.format('Wezterm keymap directory file path: %s', keymap_dir))

    local full_keymap_table = {}

    for _, keymap_file in ipairs(wezterm.read_dir(keymap_dir)) do
        local keymap_match = keymap_file:match('(WeztermStimpack.*)%.lua')
        local init_file = keymap_file:match('(WeztermStimpack.*)[/\\]init.lua')
        if keymap_match and not init_file then
            keymap_match = keymap_match:gsub('[\\/]', '.')
            print('Running command: require ' .. keymap_match)
            local sourced_keymap_file = require(keymap_match)

            if sourced_keymap_file and type(sourced_keymap_file) == 'table' then
                wezterm.log_info(
                    string.format(
                        'Valid keymap file found containing: %d items, path: %s',
                        #sourced_keymap_file,
                        keymap_file
                    )
                )

                for _, keymap_item in pairs(sourced_keymap_file) do
                    table.insert(full_keymap_table, keymap_item)
                end

                wezterm.log_info(string.format('full_keymap_table now has: %d items', #full_keymap_table))
            else
                wezterm.log_info(
                    string.format(
                        'The file: %s, did not return a table - this will not be sourced',
                        sourced_keymap_file
                    )
                )
            end
        end
    end

    -- Assign keymaps
    if type(full_keymap_table) == 'table' and #full_keymap_table > 0 then
        return full_keymap_table
    else
        return {}
    end
end

return M
