# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

WezTerm terminal emulator configuration, written entirely in Lua. The user also uses a stenography keyboard, which is why some keymaps use special Unicode characters as key values.

## Formatting and Linting

- **Formatter**: StyLua — config in `.stylua.toml` (single quotes, 4-space indent, 120 col width, Unix line endings)
- Run: `stylua .` from the repo root
- **Commits**: Conventional Commits enforced via commitizen pre-commit hook (`.cz.toml`, `.pre-commit-config.yaml`)
- **Line endings**: LF everywhere (`.gitattributes` enforces `eol=lf`)

## Architecture

`wezterm.lua` is the entrypoint. It builds a `config` object and delegates to modules in `WeztermStimpack/`:

- **Config-mutating modules** expose `M.init(config)` — they receive the config table and modify it directly (e.g., `bell-settings`, `font-settings`, `tab-format`)
- **Value-returning modules** return a table assigned to a config key (e.g., `colors`, `ssh-domains`, `hyperlink-rules`, `quick-select-patterns`)
- **Event-registering modules** are `require`'d for side effects — they call `wezterm.on(...)` to register event handlers (e.g., `right-status-format`, `gui-startup`)

### Keymap System

Default keybindings are disabled (`disable_default_key_bindings = true`). The leader key is `Ctrl+a` (tmux-style).

`WeztermStimpack/keymaps/init.lua` auto-discovers all `.lua` files in its directory (skipping `init.lua` itself), requires each one, and merges their returned tables into a single keymap list. To add keymaps, drop a new `.lua` file in `WeztermStimpack/keymaps/` that returns a table of keymap entries.

Key table modes (copy_mode, search_mode) are in `keymap-tables.lua`.

### Project Workspaces

`projects/` contains per-project workspace definitions loaded at `gui-startup`. Files here are gitignored (except `HowToUseProjectWorkspaces.md`). Each file uses `mux.spawn_window()` to create named workspaces with specific tabs/panes. Drop a `.lua` file here for temporary project layouts without touching the repo.

## Key Conventions

- Modules use the `local M = {} ... return M` pattern
- Type annotations use `---@type` and `---@param` LuaDoc comments with WezTerm types (`Wezterm`, `Config`)
- `crossplatform.lua` provides path utilities that handle Windows vs Unix path separators via `wezterm.target_triple`
- Bundled fonts live in `fonts/` (Fira Code, Hack Nerd Font, Hermit, Nerd Fonts Symbols) — these are binary and tracked in git