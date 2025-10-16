#!/usr/bin/env sh
HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ] ; then
    # Enter gamemode - disable visual effects
    hyprctl --batch "\
	keyword animations:enabled 0;\
        keyword animation borderangle,0; \
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:enabled 0;\
	keyword decoration:fullscreen_opacity 1;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0"

    powerprofilesctl set performance
    notify-send "Gaming Mode Activated" "Visual effects disabled\nPerformance power profile enabled"

    exit
fi
hyprctl reload
powerprofilesctl set balanced
notify-send "$(cat /etc/hostname) HyprLand ⚙️" "Holding..."
