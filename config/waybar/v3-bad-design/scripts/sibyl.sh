#!/usr/bin/env bash
# sibyl.sh - waybar custom module: what SIBYL claims about you (same logic as the lockscreen)
# Prints one JSON line: {"text","class","tooltip"}; waybar runs it every second.
#   < 100  clear (ice)  | 100-299 cloudy (violet) | 300+ critical (red)
#   about once every 23 s the reading glitches to ???  (one timestamp is wrong)
# Range: edit CC_MIN / CC_MAX (or export SIBYL_MIN / SIBYL_MAX).

CC_MIN="${SIBYL_MIN:-60}"
CC_MAX="${SIBYL_MAX:-140}"

t=$(date +%s)
r=$(( (t * 1103515245 + 12345) / 65536 % 32768 ))
n=$(( CC_MIN + r % (CC_MAX - CC_MIN + 1) ))

if [ $(( t % 23 )) -eq 0 ]; then
    cls=glitch;   txt="???"
    tip='SIBYL · RECHECKING\nreading unverified'
elif [ "$n" -ge 300 ]; then
    cls=critical; txt=$(printf '%03d' "$n")
    tip='HUE: CLOUDY\nDOMINATOR · LETHAL ELIMINATOR'
elif [ "$n" -ge 100 ]; then
    cls=cloudy;   txt=$(printf '%03d' "$n")
    tip='HUE: CLOUDY\nDOMINATOR · NON-LETHAL PARALYZER'
else
    cls=clear;    txt=$(printf '%03d' "$n")
    tip='HUE: CLEAR\nDOMINATOR · TRIGGER LOCKED'
fi

printf '{"text":"%s","class":"%s","tooltip":"CRIME COEFFICIENT %s\\n%s"}\n' "$txt" "$cls" "$txt" "$tip"
