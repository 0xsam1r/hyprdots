#!/usr/bin/env bash

#======================================================
cat << 'EOF'
    ____ _   __   _       __              __    _                                                                   
   /  _// | / /  | |     / /____   _____ / /__ (_)____   ____ _                                                     
   / / /  |/ /   | | /| / // __ \ / ___// //_// // __ \ / __ `/                                                     
 _/ / / /|  /    | |/ |/ // /_/ // /   / ,<  / // / / // /_/ /_  _  _  _  _  _                                      
/___//_/ |_/     |__/|__/ \____//_/   /_/|_|/_//_/ /_/ \__, /(_)(_)(_)(_)(_)(_)                                     
    ____          __   __                        _   _/____/   __   _  ____ _               __   _                  
   / __ ) ____ _ / /_ / /_ ___   _____ __  __   / | / /____   / /_ (_)/ __/(_)_____ ____ _ / /_ (_)____   ____      
  / __  |/ __ `// __// __// _ \ / ___// / / /  /  |/ // __ \ / __// // /_ / // ___// __ `// __// // __ \ / __ \     
 / /_/ // /_/ // /_ / /_ /  __// /   / /_/ /  / /|  // /_/ // /_ / // __// // /__ / /_/ // /_ / // /_/ // / / /     
/_____/ \__,_/ \__/ \__/ \___//_/    \__, /  /_/ |_/ \____/ \__//_//_/  /_/ \___/ \__,_/ \__//_/ \____//_/ /_/      
                                    /____/                                                                          
EOF

exit 1
#======================================================

battery_low=20
battery_critical=5
battery_full=85
check_interval=60
last_notified=0
last_status=""
execute_critical="systemctl suspend"

print_log() {
    while (("$#")); do
        case "$1" in
        -r) echo -ne "\e[31m$2\e[0m" >&2; shift 2 ;;
        -g) echo -ne "\e[32m$2\e[0m" >&2; shift 2 ;;
        -y) echo -ne "\e[33m$2\e[0m" >&2; shift 2 ;;
        -stat) echo -ne "\e[4;30;46m $2 \e[0m :: " >&2; shift 2 ;;
        *) echo -ne "$1" >&2; shift ;;
        esac
    done
    echo "" >&2
}

notify() {
    local urgency="$1"
    local title="$2"
    local body="$3"
    local icon="$4"

    notify-send -a "🔋 بطارية" -u "$urgency" -i "$icon" "$title" "$body"
    print_log -stat "Battery" -y "$title" "$body"
}

check_battery() {
    local percent status

    percent=$(cat /sys/class/power_supply/BAT*/capacity)
    status=$(cat /sys/class/power_supply/BAT*/status)

    # إشعار عند تغيير حالة الشحن (بداية شحن أو فصل شحن)
    if [[ "$status" != "$last_status" ]]; then
        case "$status" in
            "Charging")
                notify "normal" "🔌 بدأ الشحن" "البطارية الآن ${percent}٪" "battery-good-symbolic"
                ;;
            "Discharging")
                notify "normal" "🔋 فصل الشحن" "الجهاز يعمل على البطارية (${percent}٪)" "battery-missing-symbolic"
                ;;
        esac
        last_status="$status"
    fi

    # إشعار عند امتلاء البطارية
    if [[ "$status" == "Charging" && $percent -ge $battery_full ]]; then
        if (( percent - last_notified >= 5 )); then
            notify "normal" "💯 فصل الشاحن" "البطارية وصلت $percent٪" "battery-full-symbolic"
            last_notified=$percent
        fi
    elif [[ "$status" == "Discharging" ]]; then
        if (( percent <= battery_critical )); then
            notify "critical" "🔴 بطارية حرجة" "سيتم تعليق الجهاز!" "battery-caution-symbolic"
            $execute_critical
        elif (( percent <= battery_low && last_notified - percent >= 5 )); then
            notify "critical" "⚠️ بطارية منخفضة" "تبقّى $percent٪، الرجاء الشحن" "battery-low-symbolic"
            last_notified=$percent
        fi
    fi
}

while true; do
    check_battery
    sleep "$check_interval"
done
