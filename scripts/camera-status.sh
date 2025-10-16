#                                                            __          __              
#   _____ ____ _ ____ ___   ___   _____ ____ _        _____ / /_ ____ _ / /_ __  __ _____
#  / ___// __ `// __ `__ \ / _ \ / ___// __ `/______ / ___// __// __ `// __// / / // ___/
# / /__ / /_/ // / / / / //  __// /   / /_/ //_____/(__  )/ /_ / /_/ // /_ / /_/ /(__  ) 
# \___/ \__,_//_/ /_/ /_/ \___//_/    \__,_/       /____/ \__/ \__,_/ \__/ \__,_//____/                                                                                         
#----------------------------------------------------------------
# Written by Samir Ahmed
# Repository Link: https://github.com/samir176520/dotfiles
#-----------------------------------------------------------------

#!/bin/bash

STATE_FILE="/tmp/.camera_active"

# Check if camera device exists
if [ ! -e /dev/video0 ]; then
  echo '{"text":"×","class":"disabled"}'
  rm -f "$STATE_FILE"
  exit 0
fi

# Check if camera is in use
if fuser /dev/video0 > /dev/null 2>&1; then
  echo '{"text":"󰄀","class":"active"}'

  # Send notification only once when camera activates
  if [ ! -f "$STATE_FILE" ]; then
    notify-send -u normal -i camera-video "📷 Camera Activated" "An application is using your camera"
    touch "$STATE_FILE"
  fi
else
  echo '{"text":"","class":"inactive"}'
  rm -f "$STATE_FILE"
fi