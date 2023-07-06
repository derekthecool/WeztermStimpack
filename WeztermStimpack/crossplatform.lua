-- Wezterm modules
local wezterm = require('wezterm')
local mux = wezterm.mux

local M = {}

M.path = {}

M.path.separator = function()
    if require('wezterm').target_triple == 'x86_64-pc-windows-msvc' then
        return [[\]]
    else
        return '/'
    end
end

---Split string into a table of strings using a separator.
---Found here https://www.reddit.com/r/neovim/comments/su0em7/comment/hx96ur0/?utm_source=share&utm_medium=web3x
---@param inputString string The string to split.
---@param sep string The separator to use.
---@return table table A table of strings.
M.path.split = function(inputString, sep)
    local fields = {}

    local pattern = string.format('([^%s]+)', sep)
    local _ = string.gsub(inputString, pattern, function(c)
        fields[#fields + 1] = c
    end)

    return fields
end

---Joins arbitrary number of paths together.
---Found here https://www.reddit.com/r/neovim/comments/su0em7/comment/hx96ur0/?utm_source=share&utm_medium=web3x
---@vararg <string> The paths to join.
---@return string
M.path.join_path = function(...)
    local args = { ... }
    if #args == 0 then
        return ''
    end

    local all_parts = {}
    if type(args[1]) == 'string' and args[1]:sub(1, 1) == M.path.separator then
        all_parts[1] = ''
    end

    for _, arg in ipairs(args) do
        local arg_parts = M.path.split(arg, M.path.separator)
        for _, path in ipairs(arg_parts) do
            table.insert(all_parts, path)
        end
    end
    local output_path = table.concat(all_parts, M.path.separator())
    wezterm.log_info('Join_path created: ' .. output_path)
    return output_path
end

return M
