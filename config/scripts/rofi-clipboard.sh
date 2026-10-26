#!/usr/bin/env bash
THEME="$HOME/.config/rofi/clipboard.rasi"

choice=$(cliphist list | rofi -dmenu -theme "$THEME" -p "Query://")

[[ -n $choice ]] && cliphist decode <<<"$choice" | wl-copy
