# ChatGPT Mini workspace workaround

`exec-on-workspace-change` runs `follow-chatgpt-mini.sh`. On every workspace switch it discovers Mini and moves it to the current workspace without focusing it. The existing Control+Shift+Command+K shortcut stays in ChatGPT.

No window registration is needed after restarting ChatGPT or rebooting. Identification assumes exactly one floating ChatGPT window titled ChatGPT and a tiled main window in the same process. If the main window is floated or additional floating ChatGPT windows are open, detection may stop. Keep the main window tiled. This is a heuristic, not an app-provided Mini identifier.

The callback resolves the script under `$HOME/code/dotfiles/aerospace/`. The script finds AeroSpace under either Homebrew prefix. On another Mac with these dotfiles installed there, pull the changes, enable Mini and its shortcut in ChatGPT, and run `aerospace reload-config`. Mini follows on the next workspace switch.

Validation: shell syntax and config reload passed; current window discovery ran successfully. Synthetic detection checks passed for new IDs after restart, multiple floating windows, a lone floated main window, and a closed app. Actual ChatGPT restart remains untested.

Known limitations: controls follow all workspaces and can sometimes be covered by another window. No shortcut wrapper or focus stealing is installed.

Disable by removing `exec-on-workspace-change` from `aerospace.toml` and running `aerospace reload-config`.
