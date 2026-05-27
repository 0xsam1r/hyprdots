#!/bin/bash
#  ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗  █████╗ ██████╗ ███████╗██████╗
#  ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
#  ██║ █╗ ██║███████║██║     ██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝
#  ██║███╗██║██╔══██║██║     ██║     ██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
#  ╚███╔███╔╝██║  ██║███████╗███████╗██║     ██║  ██║██║     ███████╗██║  ██║
#   ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
#
#  ██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗███████╗██████╗
#  ██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║██╔════╝██╔══██╗
#  ██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║█████╗  ██████╔╝
#  ██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║██╔══╝  ██╔══██╗
#  ███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████╗██║  ██║
#  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
#	originally written by: gh0stzk - https://github.com/gh0stzk/dotfiles
#	rewritten for hyprland by :	 develcooking - https://github.com/develcooking/hyprland-dotfiles
#	Info    - This script runs the rofi launcher, to select
#             the wallpapers included in the theme you are in.

# Set some variables
wall_dir="${HOME}/Pictures/wallpapers/"
cache_dir="${HOME}/.cache/thumbnails/wal_selector"
rofi_config_path="${HOME}/.config/rofi/wallSelect.rasi"
rofi_command="rofi -dmenu -config ${rofi_config_path}"

# Fix 1: Initialize Fontconfig properly
export FONTCONFIG_PATH=/etc/fonts

# Fix 2: Suppress ImageMagick warnings


# Create cache dir if not exists
if [ ! -d "${cache_dir}" ] ; then
    mkdir -p "${cache_dir}"
fi

# Fix 3: Only process valid image files
while IFS= read -r -d '' imagen; do
    filename=$(basename "$imagen")
    
    # Skip if thumbnail already exists
    [ -f "${cache_dir}/${filename}" ] && continue
    
    # Fix 4: Validate file before processing
    if file -b --mime-type "$imagen" | grep -q '^image/'; then
        # Fix 5: Handle processing failures
        if ! magick "$imagen" -strip -thumbnail 500x500^ -gravity center -extent 500x500 "${cache_dir}/${filename}" 2>/dev/null; then
            # Create placeholder for invalid images
            magick -size 500x500 xc:gray -pointsize 20 -fill white -gravity center \
                   -annotate 0 "Invalid Image" "${cache_dir}/${filename}" 2>/dev/null
        fi
    else
        # Create placeholder for non-image files
        magick -size 500x500 xc:red -pointsize 20 -fill white -gravity center \
               -annotate 0 "Not an Image" "${cache_dir}/${filename}" 2>/dev/null
    fi
done < <(find "$wall_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0)

# Fix 6: Create selection list with fallbacks
wall_selection=$(
    find "$wall_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | \
    while IFS= read -r -d '' file; do 
        filename=$(basename "$file")
        # Check if thumbnail exists
        if [ -f "${cache_dir}/${filename}" ]; then
            echo -en "${filename}\x00icon\x1f${cache_dir}/${filename}\n"
        else
            # Fallback to generic icon
            echo -en "${filename}\x00icon\x1fapplication-x-executable\n"
        fi
    done | $rofi_command
)

# Set the wallpaper with waypaper
if [[ -n "$wall_selection" ]]; then
    # Final validation before setting
    if file -b --mime-type "${wall_dir}${wall_selection}" | grep -q '^image/'; then
        waypaper --wallpaper "${wall_dir}${wall_selection}"
    else
        notify-send "Wallpaper Error" "Selected file is not a valid image: $wall_selection"
        exit 1
    fi
else
    exit 0
fi

exit 0