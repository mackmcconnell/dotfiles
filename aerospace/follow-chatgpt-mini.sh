#!/bin/bash
# ChatGPT Mini AeroSpace fix: prevents the Mini shortcut from jumping workspaces.
# Called by aerospace.toml on workspace changes; rediscovers Mini after restarts.
# Assumes one floating ChatGPT window and a tiled main window. See chatgpt-mini.md.
set -eu
for candidate in /opt/homebrew/bin/aerospace /usr/local/bin/aerospace; do
    if [[ -x "$candidate" ]]; then AEROSPACE="$candidate"; break; fi
done
[[ -n "${AEROSPACE:-}" ]] || exit 0
windows="$($AEROSPACE list-windows --monitor all --app-bundle-id com.openai.codex \
    --format '%{window-id}|%{app-pid}|%{window-layout}|%{workspace}|%{window-title}')"
# Do nothing if multiple floating windows make identification ambiguous.
row=$(printf '%s\n' "$windows" | awk -F '|' '
    $3 == "floating" { count++; candidate=$0; pid=$2; title=$5 }
    $3 != "floating" { tiled[$2]=1 }
    END { if (count == 1 && tiled[pid] && title == "ChatGPT") print candidate }
')
[[ -n "$row" ]] || exit 0
IFS='|' read -r window_id app_pid window_layout window_workspace window_title <<< "$row"
unset AEROSPACE_WINDOW_ID AEROSPACE_WORKSPACE
workspace="$($AEROSPACE list-workspaces --focused)"
[[ -n "$workspace" && "$workspace" != "$window_workspace" ]] || exit 0
$AEROSPACE move-node-to-workspace --window-id "$window_id" "$workspace"
