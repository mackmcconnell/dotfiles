#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Mack OS in Ghostty + CC
# @raycast.mode silent

osascript <<'EOF'
  tell application "Ghostty" to activate
  delay 0.5
  tell application "System Events"
      keystroke "cd ~/code/mack_os && claude\r"
  end tell
  EOF