return {
    visual_bell = '#202020',
    -- Colors for copy_mode and quick_select
    -- available since: 20220807-113146-c2fee766
    -- In copy_mode, the color of the active text is:
    -- 1. copy_mode_active_highlight_* if additional text was selected using the mouse
    -- 2. selection_* otherwise
    -- use `AnsiColor` to specify one of the ansi color palette values
    -- (index 0-15) using one of the names "Black", "Maroon", "Green",
    --  "Olive", "Navy", "Purple", "Teal", "Silver", "Grey", "Red", "Lime",
    -- "Yellow", "Blue", "Fuchsia", "Aqua" or "White".
    copy_mode_active_highlight_bg = { Color = '#3b009f' },
    copy_mode_active_highlight_fg = { Color = '#ffffff' },
    copy_mode_inactive_highlight_bg = { Color = '#6e00d2' },
    copy_mode_inactive_highlight_fg = { Color = '#fa0046' },
    quick_select_label_bg = { Color = '#00ff00' },
    quick_select_label_fg = { Color = '#222222' },
    quick_select_match_bg = { Color = '#009600' },
    quick_select_match_fg = { Color = '#000000' },
    tab_bar = {
        -- The color of the strip that goes along the top of the window
        -- (does not apply when fancy tab bar is in use)
        background = '#202746',
        -- The active tab is the one that has focus in the window
        active_tab = {
            -- The color of the background area for the tab
            bg_color = '#202746',
            -- The color of the text for the tab
            fg_color = '#c0c0c0',
            -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
            -- label shown for this tab.
            -- The default is "Normal"
            intensity = 'Normal',
            -- Specify whether you want "None", "Single" or "Double" underline for
            -- label shown for this tab.
            -- The default is "None"
            underline = 'None',
            -- Specify whether you want the text to be italic (true) or not (false)
            -- for this tab.  The default is false.
            italic = false,
            -- Specify whether you want the text to be rendered with strikethrough (true)
            -- or not for this tab.  The default is false.
            strikethrough = false,
        },
        -- Inactive tabs are the tabs that do not have focus
        inactive_tab = {
            bg_color = '#121938',
            fg_color = '#808080',
            -- The same options that were listed under the `active_tab` section above
            -- can also be used for `inactive_tab`.
        },
        -- You can configure some alternate styling when the mouse pointer
        -- moves over inactive tabs
        inactive_tab_hover = {
            bg_color = '#3b3052',
            fg_color = '#909090',
            italic = true,
            -- The same options that were listed under the `active_tab` section above
            -- can also be used for `inactive_tab_hover`.
        },
    },
    -- Cursor color settings
    cursor_bg = '#52ad70',
    cursor_fg = 'black',
    cursor_border = '#52ad70',
    -- Used during leader key press
    compose_cursor = '#00ff00',
}
