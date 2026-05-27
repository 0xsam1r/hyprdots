#!/usr/bin/env bash

# Switch to next keyboard layout for all devices
niri msg action switch-layout next

# Get current layout from the main keyboard
current_layout=$(niri msg -j keyboard-layouts | jq -r '.names[.current_idx]')

# Send notification
notify-send "Keyboard Layout" "Switched to: $current_layout"
