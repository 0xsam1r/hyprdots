#!/usr/bin/env bash

# Configure your outputs
SOURCE=$(niri msg --json focused-output | jq -r .name)
TARGET="HDMI-A-2"

# Check if wl-mirror is running
if pgrep -x "wl-mirror" > /dev/null; then
    notify-send -i display "Mirror State" "Another instanse is running."
    # pkill wl-mirror
    exit 2
fi

SOURCE=$(niri msg --json focused-output | jq -r .name)
TARGET="HDMI-A-2"

# notify-send "Starting wl-mirror" "$SOURCE → $TARGET"
wl-mirror --fullscreen-output "$TARGET" "$SOURCE"
if [[ $? -eq 0 ]] ; then 
   notify-send -i display "Mirror started" "Source: $SOURCE → Output: $TARGET";
else
    notify-send -i display "Mirror Fail" "Is $TARGET connected ?";
fi

