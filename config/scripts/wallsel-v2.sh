#!/usr/bin/env bash
# wallsel - rofi wallpaper selector, single row of portrait cards
# Deps: rofi, imagemagick, findutils, coreutils, + one backend (awww/swww, hyprpaper, swaybg)

set -u

# =====================================================================
#  LOOK SETTINGS  (edit here, or override with env vars, e.g.
#  WALLSEL_FONT_SIZE=14 ./wallsel.sh). All sizes are in pixels.
# =====================================================================

# --- cards: size / spacing ---
# Card width is computed so each card fills its column exactly
# (that is what makes the highlight hug the card with no side margins).
COLUMNS_N="${WALLSEL_COLUMNS:-6}"        # cards per page
GAP="${WALLSEL_GAP:-40}"                 # space between cards
BAR_PAD_X="${WALLSEL_BAR_PAD_X:-40}"     # bar padding left/right
BAR_PAD_Y="${WALLSEL_BAR_PAD_Y:-40}"     # bar padding top/bottom
CARD_RATIO="${WALLSEL_CARD_RATIO:-150}"  # card height as % of width (150 = 2:3 portrait)
CARD_RADIUS="${WALLSEL_CARD_RADIUS:-28}" # corner roundness of cards and highlight
SCREEN_W="${WALLSEL_SCREEN_W:-}"         # set manually if auto-detect is wrong

# --- selected-card highlight ---
HL_COLOR="${WALLSEL_HL_COLOR:-rgba(150, 180, 205, 55%)}"
HL_BORDER="${WALLSEL_HL_BORDER:-0}" # e.g. "2px" to add an outline
HL_BORDER_COLOR="${WALLSEL_HL_BORDER_COLOR:-#e6e9ff}"

# --- label (filename under each card) ---
FONT="${WALLSEL_FONT:-JetBrainsMono Nerd Font}"
FONT_SIZE="${WALLSEL_FONT_SIZE:-12}"
FONT_BOLD="${WALLSEL_FONT_BOLD:-1}" # 1 = bold, clearer on busy backgrounds
LABEL_COLOR="${WALLSEL_LABEL_COLOR:-#e6e9ff}"
LABEL_SELECTED_COLOR="${WALLSEL_LABEL_SELECTED_COLOR:-#ffffff}"
LABEL_PAD="${WALLSEL_LABEL_PAD:-14}"    # space below the label inside the highlight
LABEL_NOEXT="${WALLSEL_LABEL_NOEXT:-1}" # 1 = hide ".png"/".jpg" (long names fit better)
LABEL_UPPER="${WALLSEL_LABEL_UPPER:-0}" # 1 = UPPERCASE labels

# --- bar background ---
BAR_BG="${WALLSEL_BAR_BG:-rgba(10, 12, 38, 90%)}"

# =====================================================================

WALL_DIR="${WALL_DIR:-$HOME/Pictures/wallpapers}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallsel"
CURRENT_LINK="$CACHE_DIR/current"

# ---------- geometry ----------
detect_screen_w() {
    # logical width of the first Hyprland monitor (pixels / scale)
    command -v hyprctl >/dev/null || return 1
    hyprctl monitors 2>/dev/null | awk '
        /^[[:space:]]+[0-9]+x[0-9]+@/ && !w { split($1, a, "x"); w = a[1] }
        /scale:/ && !s { s = $2 }
        END { if (w) printf "%d", w / (s ? s : 1) }'
}
[ -z "$SCREEN_W" ] && SCREEN_W=$(detect_screen_w)
[ -z "$SCREEN_W" ] && SCREEN_W=1920

CARD_W=$(((SCREEN_W - 2 * BAR_PAD_X - (COLUMNS_N - 1) * GAP) / COLUMNS_N))
CARD_H=$((CARD_W * CARD_RATIO / 100))

# thumbnails are rendered at 2x so they stay sharp when rofi scales them
THUMB_W=$((CARD_W * 2))
THUMB_H=$((CARD_H * 2))
THUMB_R=$((CARD_RADIUS * 2))
export THUMB_W THUMB_H THUMB_R

THUMB_DIR="$CACHE_DIR/thumbs-${THUMB_W}x${THUMB_H}"
mkdir -p "$THUMB_DIR"

# ---------- collect wallpapers ----------
mapfile -d '' walls < <(
    find -L "$WALL_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) \
        -print0 | sort -z
)
if [ "${#walls[@]}" -eq 0 ]; then
    echo "No wallpapers found in $WALL_DIR" >&2
    exit 1
fi

# ---------- thumbnail cache ----------
thumb_for() {
    local key
    key=$(printf '%s:%s:%s' "$1" "$(stat -c %Y "$1")" "$THUMB_R" | md5sum | cut -d' ' -f1)
    printf '%s/%s.png' "$THUMB_DIR" "$key"
}

# portrait crop (center), top corners rounded via an alpha mask
make_thumb() {
    local wall="$1" out="$2"
    [ -e "$out" ] && return 0
    magick "$wall[0]" -strip -thumbnail "${THUMB_W}x${THUMB_H}^" -gravity center \
        -extent "${THUMB_W}x${THUMB_H}" -alpha set \
        \( -size "${THUMB_W}x${THUMB_H}" xc:none -fill white \
        -draw "roundrectangle 0,0 $((THUMB_W - 1)),$((THUMB_H + THUMB_R)) $THUMB_R,$THUMB_R" \) \
        -compose DstIn -composite "png:$out.tmp" &&
        mv -f "$out.tmp" "$out"
}
export -f make_thumb

for w in "${walls[@]}"; do
    t=$(thumb_for "$w")
    [ -e "$t" ] || printf '%s\0%s\0' "$w" "$t"
done | xargs -0 -n2 -P"$(nproc)" bash -c 'make_thumb "$1" "$2"' _

# ---------- find current wallpaper index (to preselect it) ----------
cur_index=0
if [ -L "$CURRENT_LINK" ]; then
    cur_real=$(readlink -f "$CURRENT_LINK")
    for i in "${!walls[@]}"; do
        if [ "$(readlink -f "${walls[i]}")" == "$cur_real" ]; then
            cur_index=$i
            break
        fi
    done
fi

# ---------- rofi ----------
# Typing still filters even though the input bar is hidden.
font_str="$FONT"
[ "$FONT_BOLD" = 1 ] && font_str="$FONT Bold"

theme_str="
* {
    font: \"$font_str $FONT_SIZE\";
    background: transparent;
    text-color: $LABEL_COLOR;
}
window {
    location: center;
    anchor: center;
    width: 100%;
    background-color: $BAR_BG;
    border: 0;
    border-radius: 0;
    padding: ${BAR_PAD_Y}px ${BAR_PAD_X}px;
}
mainbox { children: [ listview ]; background-color: transparent; }
listview {
    columns: $COLUMNS_N;
    lines: 1;
    fixed-columns: true;
    spacing: ${GAP}px;
    scrollbar: false;
    cycle: true;
    background-color: transparent;
}
element {
    orientation: vertical;
    padding: 0 0 ${LABEL_PAD}px 0;
    spacing: 10px;
    border-radius: ${CARD_RADIUS}px;
    border: $HL_BORDER;
    border-color: transparent;
    background-color: transparent;
}
element selected.normal {
    background-color: $HL_COLOR;
    border-color: $HL_BORDER_COLOR;
    text-color: $LABEL_SELECTED_COLOR;
}
element-icon {
    size: ${CARD_H}px;
    border-radius: 0;
    background-color: transparent;
}
element-text {
    horizontal-align: 0.5;
    vertical-align: 0.5;
    background-color: transparent;
    text-color: inherit;
}
"

label_for() {
    local n
    n=$(basename "$1")
    [ "$LABEL_NOEXT" = 1 ] && n="${n%.*}"
    [ "$LABEL_UPPER" = 1 ] && n="${n^^}"
    printf '%s' "$n"
}

choice=$(
    for w in "${walls[@]}"; do
        printf '%s\0icon\x1f%s\n' "$(label_for "$w")" "$(thumb_for "$w")"
    done | rofi -dmenu -i -show-icons -format i -p "" \
        -selected-row "$cur_index" -theme-str "$theme_str"
)

[ -z "$choice" ] && exit 0
selected="${walls[choice]}"

# ---------- apply ----------
ln -sf "$selected" "$CURRENT_LINK"

set_wallpaper() {
    local f="$1"
    if command -v awww >/dev/null; then
        pgrep -x awww-daemon >/dev/null || {
            awww-daemon &
            sleep 0.5
        }
        awww img "$f" --transition-type grow --transition-duration 1
    elif command -v swww >/dev/null; then
        pgrep -x swww-daemon >/dev/null || {
            swww-daemon &
            sleep 0.5
        }
        swww img "$f" --transition-type grow --transition-duration 1
    elif command -v hyprctl >/dev/null && pgrep -x hyprpaper >/dev/null; then
        hyprctl hyprpaper preload "$f"
        hyprctl hyprpaper wallpaper ",$f"
    elif command -v swaybg >/dev/null; then
        pkill -x swaybg
        swaybg -i "$f" -m fill &
        disown
    else
        echo "No supported wallpaper backend found" >&2
        return 1
    fi
}

set_wallpaper "$selected"
