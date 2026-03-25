## 0.2.0 (2026-03-25)

### Feat

- **keymaps**: add LEADER+i keymap to open Claude Code in a new tab

### Fix

- **right-status-format**: fix battery index out of bounds crash at 0% charge (Lua tables are 1-indexed but `math.floor(0/10)` produced 0)
- **keymaps**: remove duplicate LEADER+l keybinding for ShowDebugOverlay

### Refactor

- **keymaps**: remove unused `urldecode` and `hex_to_char` functions
- **keymaps**: remove unused `mux` import

## 0.1.0 (2024-09-24)

### Feat

- **quick-select-patterns**: add new pattern to capture previous run commands
- **pre-commit**: add commitizen and pre-commit
- **font**: stop using local custom fonts, too many problems
- **quick-select-patterns**: update quick select alphabet and copy links
