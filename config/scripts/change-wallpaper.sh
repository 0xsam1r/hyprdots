#!/usr/bin/env bash
#================TODO=======================
# [X] rewrite the script 
# [] using thumbainlas 
#   [] using rofi theme for thumbainals
#   [] edit script to work with thumbainals
#===========================================

WALL_DIR="$HOME/Pictures/wallpapers"

# function to set wallpaper 
set_wallpaper() {
    local IMG="$1"

    # false doesn't countinue in and 
    [[ ! -f "$IMG" ]] && echo "Wallpaper Change Error" "File not found: $IMG" && notify-send "Wallpaper Error" "File not found: $IMG" && exit 1

    # command to change wallpaper
    awww img "$IMG" \
        --transition-type random

    notify-send --icon "$IMG"  " Wallpaper Changed 🎨" "Applied: $(basename "$IMG")"
}


choose_menu() {
    # choice wallpaper using rofi
    CHOICE=$(echo -e "Random\n$(ls -1v "$WALL_DIR")" | rofi -dmenu -p "󰋫 Wallpaper" -i)

    [[ -z "$CHOICE" ]] && exit 0

    # select one random wallpaper
    if [[ "$CHOICE" == "Random" ]]; then
        FILE=$(find -L "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | shuf -n1)
        
    else
        FILE="$WALL_DIR/$CHOICE"
    fi

    # call our function to apply wallpaper
    set_wallpaper "$FILE"
}

# apply based on input
case "$#" in
    0) choose_menu ;;
    1) set_wallpaper "$1" ;;
    *) echo "Usage: $0 [optional: image_path]" && exit 1 ;;
esac

