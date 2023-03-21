local act = require('wezterm').action

return {
    copy_mode = {
        -- Custom mappings
        { key = 'd', mods = 'CTRL', action = act.CopyMode('PageDown') },
        { key = 'd', action = act.CopyMode('PageDown') },
        { key = 'u', mods = 'CTRL', action = act.CopyMode('PageUp') },
        { key = 'u', action = act.CopyMode('PageUp') },

        -- Default mappings
        { key = 'Escape', mods = 'NONE', action = act.CopyMode('Close') },
        { key = 'c', mods = 'CTRL', action = act.CopyMode('Close') },
        { key = 'g', mods = 'CTRL', action = act.CopyMode('Close') },
        { key = 'q', mods = 'NONE', action = act.CopyMode('Close') },
        { key = ';', mods = 'NONE', action = act.CopyMode('JumpAgain') },
        { key = ',', mods = 'NONE', action = act.CopyMode('JumpReverse') },
        { key = 'Tab', mods = 'SHIFT', action = act.CopyMode('MoveBackwardWord') },
        { key = 'b', mods = 'NONE', action = act.CopyMode('MoveBackwardWord') },
        { key = 'b', mods = 'ALT', action = act.CopyMode('MoveBackwardWord') },
        { key = 'LeftArrow', mods = 'ALT', action = act.CopyMode('MoveBackwardWord') },
        { key = 'j', mods = 'NONE', action = act.CopyMode('MoveDown') },
        { key = 'DownArrow', mods = 'NONE', action = act.CopyMode('MoveDown') },
        { key = 'Tab', mods = 'NONE', action = act.CopyMode('MoveForwardWord') },
        { key = 'f', mods = 'ALT', action = act.CopyMode('MoveForwardWord') },
        { key = 'w', mods = 'NONE', action = act.CopyMode('MoveForwardWord') },
        { key = 'RightArrow', mods = 'ALT', action = act.CopyMode('MoveForwardWord') },
        { key = 'h', mods = 'NONE', action = act.CopyMode('MoveLeft') },
        { key = 'LeftArrow', mods = 'NONE', action = act.CopyMode('MoveLeft') },
        { key = 'l', mods = 'NONE', action = act.CopyMode('MoveRight') },
        { key = 'RightArrow', mods = 'NONE', action = act.CopyMode('MoveRight') },
        { key = '$', mods = 'NONE', action = act.CopyMode('MoveToEndOfLineContent') },
        { key = '$', mods = 'SHIFT', action = act.CopyMode('MoveToEndOfLineContent') },
        { key = 'G', mods = 'NONE', action = act.CopyMode('MoveToScrollbackBottom') },
        { key = 'G', mods = 'SHIFT', action = act.CopyMode('MoveToScrollbackBottom') },
        { key = 'g', mods = 'NONE', action = act.CopyMode('MoveToScrollbackTop') },
        { key = 'o', mods = 'NONE', action = act.CopyMode('MoveToSelectionOtherEnd') },
        { key = 'O', mods = 'NONE', action = act.CopyMode('MoveToSelectionOtherEndHoriz') },
        { key = 'O', mods = 'SHIFT', action = act.CopyMode('MoveToSelectionOtherEndHoriz') },
        { key = '0', mods = 'NONE', action = act.CopyMode('MoveToStartOfLine') },
        { key = '^', mods = 'NONE', action = act.CopyMode('MoveToStartOfLineContent') },
        { key = '^', mods = 'SHIFT', action = act.CopyMode('MoveToStartOfLineContent') },
        { key = 'm', mods = 'ALT', action = act.CopyMode('MoveToStartOfLineContent') },
        { key = 'Enter', mods = 'NONE', action = act.CopyMode('MoveToStartOfNextLine') },
        { key = 'L', mods = 'NONE', action = act.CopyMode('MoveToViewportBottom') },
        { key = 'L', mods = 'SHIFT', action = act.CopyMode('MoveToViewportBottom') },
        { key = 'M', mods = 'NONE', action = act.CopyMode('MoveToViewportMiddle') },
        { key = 'M', mods = 'SHIFT', action = act.CopyMode('MoveToViewportMiddle') },
        { key = 'H', mods = 'NONE', action = act.CopyMode('MoveToViewportTop') },
        { key = 'H', mods = 'SHIFT', action = act.CopyMode('MoveToViewportTop') },
        { key = 'k', mods = 'NONE', action = act.CopyMode('MoveUp') },
        { key = 'UpArrow', mods = 'NONE', action = act.CopyMode('MoveUp') },
        { key = 'f', mods = 'CTRL', action = act.CopyMode('PageDown') },
        { key = 'PageDown', mods = 'NONE', action = act.CopyMode('PageDown') },
        { key = 'b', mods = 'CTRL', action = act.CopyMode('PageUp') },
        { key = 'PageUp', mods = 'NONE', action = act.CopyMode('PageUp') },
        {
            key = 'F',
            mods = 'NONE',
            action = act.CopyMode({
                JumpBackward = { prev_char = false },
            }),
        },
        {
            key = 'F',
            mods = 'SHIFT',
            action = act.CopyMode({
                JumpBackward = { prev_char = false },
            }),
        },
        {
            key = 'T',
            mods = 'NONE',
            action = act.CopyMode({
                JumpBackward = { prev_char = true },
            }),
        },
        {
            key = 'T',
            mods = 'SHIFT',
            action = act.CopyMode({
                JumpBackward = { prev_char = true },
            }),
        },
        {
            key = 'f',
            mods = 'NONE',
            action = act.CopyMode({
                JumpForward = { prev_char = false },
            }),
        },
        {
            key = 't',
            mods = 'NONE',
            action = act.CopyMode({
                JumpForward = { prev_char = true },
            }),
        },
        { key = 'v', mods = 'CTRL', action = act.CopyMode({ SetSelectionMode = 'Block' }) },
        { key = 'Space', mods = 'NONE', action = act.CopyMode({ SetSelectionMode = 'Cell' }) },
        { key = 'v', mods = 'NONE', action = act.CopyMode({ SetSelectionMode = 'Cell' }) },
        { key = 'V', mods = 'NONE', action = act.CopyMode({ SetSelectionMode = 'Line' }) },
        { key = 'V', mods = 'SHIFT', action = act.CopyMode({ SetSelectionMode = 'Line' }) },
        {
            key = 'y',
            mods = 'NONE',
            action = act.Multiple({ { CopyTo = 'ClipboardAndPrimarySelection' }, { CopyMode = 'Close' } }),
        },
    },
    search_mode = {
        -- Custom mappings
        -- This mapping fails to scroll, instead it clears the search input
        { key = 'd', mods = 'CTRL', action = act.CopyMode('PriorMatchPage') },
        { key = 'u', mods = 'CTRL', action = act.CopyMode('NextMatchPage') },

        -- Default mappings
        { key = 'Enter', mods = 'NONE', action = act.CopyMode('PriorMatch') },
        { key = 'Escape', mods = 'NONE', action = act.CopyMode('Close') },
        { key = 'n', mods = 'CTRL', action = act.CopyMode('NextMatch') },
        { key = 'p', mods = 'CTRL', action = act.CopyMode('PriorMatch') },
        { key = 'r', mods = 'CTRL', action = act.CopyMode('CycleMatchType') },
        { key = 'u', mods = 'CTRL', action = act.CopyMode('ClearPattern') },
        { key = 'PageUp', mods = 'NONE', action = act.CopyMode('PriorMatchPage') },
        { key = 'PageDown', mods = 'NONE', action = act.CopyMode('NextMatchPage') },
        { key = 'UpArrow', mods = 'NONE', action = act.CopyMode('PriorMatch') },
        { key = 'DownArrow', mods = 'NONE', action = act.CopyMode('NextMatch') },
    },
}
