#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

set -e

# Script: auslesen.sh
# Author: Tobias Baumann aka RaptorSDS
# License: MIT
# with help of OpenAI GPT-3.5


host_pv="192.168.xxxx"
user="admin"
password="admin"
UUID1="768xxxx"
UUID2="d69xxxx"
host_db="192.168.xxx"
TOTAL=""
TOTAL_NUM=""
ACTUAL=""
ACTUAL_NUM=""


#request value
ACTUAL=$(/usr/local/bin/mi600 $host_pv $user $password webdata_now_p)
#Remove end SPACE-Char
ACTUAL_NUM=$(($ACTUAL))


#send database
wget -O - -q "http://"$host_db"/middleware/data/"$UUID1".json?operation=add&value="$ACTUAL_NUM""



#request value TOTAL
TOTAL=$(/usr/local/bin/mi600 $host_pv $user $password webdata_total_e)
#Remove end SPACE-Char
TOTAL_NUM=$(echo $TOTAL | sed 's/[[:space:]]*$//')

#check if non ZERO
if [ $TOTAL_NUM != "0.0" ]; then
#Send to DB
  wget -O - -q "http://"$host_db"/middleware/data/"$UUID2".json?operation=add&value="$TOTAL_NUM""
fi




#DAY=$(/usr/local/bin/mi600 $host_pv $user $password webdata_today_e)

#echo 'Today:'$DAY
#echo 'ACTUAL:'$ACTUAL_NUM
#echo 'TOTAL:'$TOTAL_NUM
