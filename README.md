# Wezterm

Wezterm is a great terminal emulator. My favorite feature is that it is
configurable in lua, like neovim.

## Set Log Verbosity

```powershell
# Permanently set on windows, requires an admin shell
[System.Environment]::SetEnvironmentVariable('WEZTERM_LOG', 'info', [System.EnvironmentVariableTarget]::User)

# Customize logging levels for different items like this
# This sets config items to debug, everything else to info
[System.Environment]::SetEnvironmentVariable('WEZTERM_LOG', 'config=debug,info', [System.EnvironmentVariableTarget]::User)
```
