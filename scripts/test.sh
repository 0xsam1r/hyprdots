WALL_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache/wall_thumbs"
ROFI_THEME="$HOME/.config/rofi/wallSelect.rasi"

generate_thumbs() {
    mkdir -p "$CACHE_DIR"
    for img in "$WALL_DIR"/*.{jpg,jpeg,gif,png,webp}; do
    [[ -f $img ]] || continue # || excute command after it if file not exist
    name=$(basename $img) # extract name of the picture
    thumb=$CACHE_DIR/$name
    if [[ ! -f $thumb ]] ; then
        magick "$img" -strip -thumbnail 300x300^ -gravity center -extent 300x300 "$thumb"
    fi
    done
}

menu() {
    generate_thumbs

    choice=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
  -exec basename {} \; | while read -r name; do
    echo -en "$name\x00icon\x1f${CACHE_DIR}/${name}\n"
  done | rofi -x11 -dmenu -p " Wallpaper")

  [[ -z "$choice" ]] && exit 0

  echo $WALL_DIR/$choice
}

menu