# How To Use Project Workspaces

Lua files put into this directory will be loaded/required.

It is a perfect place to load temporary project configurations without having to
keep them in this git repo.

Here is an example file named test.lua

```lua
-- Wezterm modules
local wezterm = require('wezterm')
local mux = wezterm.mux

local tab, pane, window = mux.spawn_window({
    workspace = 'test',
    cwd = wezterm.home_dir,
})

local extraTab, extraPane, extraWindow =
    window:spawn_tab({ cwd = wezterm.home_dir })
```
