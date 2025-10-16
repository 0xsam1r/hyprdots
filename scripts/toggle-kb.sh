#!/usr/bin/env bash

# Switch to next keyboard layout for all devices
hyprctl switchxkblayout all next

# Get current layout from the main keyboard
current_layout=$(hyprctl -j devices |
  jq -r '.keyboards[] | select(.main == true) | .active_keymap')

# Send notification
notify-send -a "Keyboard Layout" -t 800 "Switched to: $current_layout"
