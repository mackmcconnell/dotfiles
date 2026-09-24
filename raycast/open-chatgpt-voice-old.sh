#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ChatGPT Voice (old)
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎙
# @raycast.packageName ChatGPT

# Open ChatGPT in Safari without activating it first
open -a Safari "https://chatgpt.com"

sleep 1

# Resize window
osascript -e '
tell application "Safari"
    set bounds of front window to {50, 50, 700, 750}
end tell
'

sleep 2

# Click voice button
osascript -e '
tell application "Safari"
    do JavaScript "document.querySelector(\"button[aria-label=\\\"Start Voice\\\"]\").click();" in front document
end tell
'

sleep 1

# Shrink window
osascript -e '
tell application "Safari"
    set bounds of front window to {50, 50, 350, 400}
end tell
'
