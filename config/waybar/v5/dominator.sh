#!/usr/bin/env bash
# Dominator mode from CPU load. Save as ~/.config/waybar/dominator.sh, chmod +x
read -r _ u1 n1 s1 i1 w1 q1 sq1 _ < /proc/stat
sleep 0.4
read -r _ u2 n2 s2 i2 w2 q2 sq2 _ < /proc/stat
idle=$(( (i2 + w2) - (i1 + w1) ))
total=$(( (u2+n2+s2+i2+w2+q2+sq2) - (u1+n1+s1+i1+w1+q1+sq1) ))
usage=$(( total > 0 ? 100 * (total - idle) / total : 0 ))

if   (( usage >= 90 )); then cls="decomposer"; mode="DECOMPOSER"; lock="LETHAL: DESTROY DECOMPOSER"
elif (( usage >= 70 )); then cls="eliminator"; mode="ELIMINATOR"; lock="LETHAL: ELIMINATOR"
else                         cls="paralyzer";  mode="PARALYZER";  lock="NON-LETHAL: PARALYZER"
fi

printf '{"text":"◈ %s","class":"%s","tooltip":"DOMINATOR\\nSafety lock: released\\nMode: %s\\nCrime Coefficient: %03d"}\n' \
  "$mode" "$cls" "$lock" "$usage"
