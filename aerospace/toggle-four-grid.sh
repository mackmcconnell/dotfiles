#!/bin/bash

set -euo pipefail

AEROSPACE_BIN="/usr/local/bin/aerospace"

# AeroSpace forwards the triggering window through these variables. Clear them
# so every command operates on the current workspace or an explicit window ID.
as() {
    env -u AEROSPACE_WINDOW_ID -u AEROSPACE_WORKSPACE "$AEROSPACE_BIN" "$@"
}

flatten_to_horizontal() {
    as flatten-workspace-tree
    local root_layout
    root_layout="$(as list-windows --workspace focused --format '%{workspace-root-container-layout}' | head -n 1)"
    if [[ "$root_layout" != "h_tiles" ]]; then
        as layout h_tiles
    fi
}

window_count="$(as list-windows --workspace focused --count)"
if [[ "$window_count" != "4" ]]; then
    osascript -e "display notification \"Current workspace has ${window_count} windows; expected 4.\" with title \"AeroSpace grid toggle\""
    exit 0
fi

focused_window_id="$(as list-windows --focused --format '%{window-id}' 2>/dev/null || true)"
root_layout="$(as list-windows --workspace focused --format '%{workspace-root-container-layout}' | head -n 1)"
parent_layouts="$(as list-windows --workspace focused --format '%{window-parent-container-layout}' | sort -u)"

if [[ "$root_layout" == "h_tiles" && "$parent_layouts" == "v_tiles" ]]; then
    # 2x2 grid -> four side-by-side columns.
    flatten_to_horizontal
else
    # Any four-window tiling tree -> deterministic 2x2 grid.
    window_ids=( $(as list-windows --workspace focused --format '%{window-id}') )
    flatten_to_horizontal
    as join-with --window-id "${window_ids[0]}" right
    as join-with --window-id "${window_ids[2]}" right
fi

as balance-sizes

if [[ -n "$focused_window_id" ]]; then
    as focus --window-id "$focused_window_id"
fi
