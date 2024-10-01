return {
    -- Matches: a URL in parens: (URL)
    -- (https://dereklomax.com]
    -- 2024-09-25 modification to allow '=' in url (flutter dev tool link)
    -- http://127.0.0.1:9100?uri=http://127.0.0.1:59933/Z_BXwEbHqH0=
    {
        regex = [[(\w+://\S+\b)]],
        format = '$1',
        highlight = 1,
    },

    -- -- Url without leading http:// or https://
    -- -- dereklomax.com
    -- {
    --     regex = [[(\w+\.(com|edu|org))]],
    --     format = 'http://$1',
    --     highlight = 0,
    -- },

    -- implicit mailto link
    -- derekthecool@gmail.com
    {
        regex = '\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b',
        format = 'mailto:$0',
    },

    -- make task numbers clickable
    -- the first matched regex group is captured in $1.
    -- t1234567
    {
        regex = [[\b[tt](\d+)\b]],
        format = 'https://example.com/tasks/?t=$1',
    },

    -- make username/project paths clickable. this implies paths like the following are for github.
    -- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wez/wezterm | "wez/wezterm.git" )
    -- as long as a full url hyperlink regex exists above this it should not match a full url to
    -- github or gitlab / bitbucket (i.e. https://gitlab.com/user/project.git is still a whole clickable url)
    {
        regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
        format = 'https://www.github.com/$1/$3',
    },
}
