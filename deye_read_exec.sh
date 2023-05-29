#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#set -e / set -u stop scripts if something is wrong
set -e
set -u

# Script: deye_read_exec.sh
# Author: Tobias Baumann aka RaptorSDS
# License: MIT
# with help of OpenAI GPT-3.5 and VZlogger Group
# idee by script for KOSTAL_Pico JSON VZlogger exec 



# Function to display script usage
usage() {
  echo "Usage: $0 <hostname> <reading1> <reading2> ..."
  exit 1
}

# Validate required arguments
if [ "$#" -lt 2 ]; then
  usage
fi

# Extract hostname
HOSTNAME="$1"
shift

# Extract readings
READINGS="$*"

user="admin"
password="admin"

# Request values based on input readings
for READING in $READINGS; do
  if [ "$READING" == "ACTUAL" ]; then
    ACTUAL=$(/usr/local/bin/mi600 "$HOSTNAME" "$user" "$password" webdata_now_p)
    #Remove end SPACE-Char
    ACTUAL_NUM=$(($ACTUAL))
    OUTPUT="$ACTUAL_NUM"
    printf "%s = %s\n" "$READING" "$OUTPUT"
  elif [ "$READING" == "TOTAL" ]; then
    TOTAL=$(/usr/local/bin/mi600 "$HOSTNAME" "$user" "$password" webdata_total_e)
    ##Remove end SPACE-Char
    TOTAL_NUM=$(echo "$TOTAL" | sed 's/[[:space:]]*$//')
    if [ $TOTAL_NUM == "0.0" ]; then
      OUTPUT=""
    else
      OUTPUT="$TOTAL_NUM"
    fi
    printf "%s = %s\n" "$READING" "$OUTPUT"
  elif [ "$READING" == "DAY" ]; then
    DAY=$(/usr/local/bin/mi600 "$HOSTNAME" "$user" "$password" webdata_today_e)
    ##Remove end SPACE-Char
    DAY_NUM=$(echo "$DAY" | sed 's/[[:space:]]*$//')
    OUTPUT="$DAY_NUM"
    printf "%s = %s\n" "$READING" "$OUTPUT"
  else
    echo "Invalid reading: $READING"
  fi
done
