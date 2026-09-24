#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Grok Voice
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎙
# @raycast.packageName Grok

# Open Grok voice mode directly in Safari
open -a Safari "https://grok.com/?voice=true"

sleep 1

# Shrink window
osascript -e '
tell application "Safari"
    set bounds of front window to {50, 50, 350, 400}
end tell
'
