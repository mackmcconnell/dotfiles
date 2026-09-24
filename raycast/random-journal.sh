#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Random Markdown (Writer Pro 2)
# @raycast.mode silent
# @raycast.packageName Writing

APP="Writer Pro 2"
DIR1="$HOME/My Drive/mack"
DIR2="$HOME/My Drive/mack/daily"

file="$(
  /usr/bin/find "$DIR1" "$DIR2" -type f \( -iname "*.md" -o -iname "*.markdown" \) 2>/dev/null \
  | /usr/bin/awk 'BEGIN{srand()} {a[NR]=$0} END{ if(NR>0) print a[int(rand()*NR)+1] }'
)"

[[ -n "$file" ]] && /usr/bin/open -a "$APP" "$file" >/dev/null 2>&1
exit 0