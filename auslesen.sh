#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# set -e stop the script when Invert not reachable
set -e

# Script: auslesen.sh
# Author: Tobias Baumann aka RaptorSDS
# License: MIT

# additional need script from dr-ni
# https://github.com/dr-ni/mi600




#Area for Login Data
host_pv="192.xxx.xxx.xxx"
user="admin"
password="admin"
UUID1="7680efc0-xxx-xxxx-xxxx-xxxxxxx"
#UUID2=""
host_db="192.xxx.xxx.xxx"
ACTUAL=""
ACTUAL_NUM=""

#area for request data
#TOTAL=$(/usr/local/bin/mi600 $host_pv $user $password webdata_total_e)
#DAY=$(/usr/local/bin/mi600 $host_pv $user $password webdata_today_e)
ACTUAL=$(/usr/local/bin/mi600 $host_pv $user $password webdata_now_p)

#remove empty space
ACTUAL_NUM=$(($ACTUAL))

#Senden to database
wget -O - -q "http://"$host_db"/middleware/data/"$UUID1".json?operation=add&value="$ACTUAL_NUM""
#wget -O - -q "http://"$host_db"/middleware/data/"$UUID2".json?operation=add&value"$DAY""

#show value for debug
#echo 'Today:'$DAY
#echo 'ACTUAL:'$ACTUAL_NUM
