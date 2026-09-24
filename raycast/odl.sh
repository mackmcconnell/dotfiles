#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ODL
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📂
# @raycast.packageName Utils

# Documentation:
# @raycast.description Open the last downloaded file

last_file=$(ls -t ~/Downloads | head -1)

if [ -z "$last_file" ]; then
  echo "No files in Downloads"
  exit 1
fi

open ~/Downloads/"$last_file"
echo "Opened $last_file"
