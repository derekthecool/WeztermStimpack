-- Wezterm modules
local wezterm = require('wezterm')
local mux = wezterm.mux

-- Build my default set of sessions, tabs, etc.
wezterm.on('gui-startup', function(cmd)
    local args = {}
    if cmd then
        args = cmd.args
    end

    local workspaces = {
        'CommandStation',
    }

    -- Set a workspace for coding on a current project
    -- Top pane is for the editor, bottom pane is for the build tool
    local tab, build_pane, window = mux.spawn_window({
        workspace = workspaces[1],
        cwd = string.format('%s/.mywiki', wezterm.home_dir),
        args = args,
    })

    -- Open neovim to wezterm config
    build_pane:send_text('nvim README.md\r\n')
    tab:set_title('CommandStation')

    -- Build project directories as found in the directory ./projects/*.lua
    -- local project_directory_files = wezterm.read_dir(crossplatform.path.join_path(wezterm.config_dir, 'projects'))
    local project_directory_files = wezterm.read_dir(string.format('%s/projects', wezterm.config_dir))

    for i, path in ipairs(project_directory_files) do
        wezterm.log_info(string.format('File number %d = %s', i, path))

        local check_for_lua_file = path:match('(projects.*)%.lua')
        if check_for_lua_file ~= nil then
            check_for_lua_file = check_for_lua_file:gsub('[\\/]', '.')
            print('Running command: require ' .. check_for_lua_file)
            require(check_for_lua_file)
        end
    end

    mux.set_active_workspace(workspaces[1])
end)
