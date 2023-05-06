#!/bin/bash

#
# Script for PRTG sensor 'Linux Updates' on yum-based Linux distributions.
#
# Return:
#   Chanel1 - Days since last linux update (yum history)
#   Chanel2 - Number of packages for update (yum update)
#   Chanel3 - The age (in days) of the oldest package from the list for update (based on the file date of the RPM package in the repository)
#
# Sensor type is "sshscript".
#
# Script executed under user 'prtg'
# Script required sudo permissions to access yum history
#
# Sudo settings:
#    prtg  ALL=(ALL) NOPASSWD:/usr/bin/yum history

DaysAlert=90
DaysWarning=60
DaysNotification=30

listPkg4Update=$(/usr/bin/yum check-update -q)
nPgksUpdate=$(echo "$listPkg4Update"|grep -c .)

lUpdate=$(sudo /usr/bin/yum history |tee -a /tmp/y_history--temp.txt|grep -E "Update|:.. .*., U"|awk 'BEGIN {FS="|"};{print $3" "$4}'|head -n 1|awk '{print $1}')
nDaysLastUpdate=`echo "( "$(date +%s) " - " $(date -d "$lUpdate" +%s) ") / 60/60/24" |bc -l`

echo "<prtg>"
echo -e "<result>"

echo "  <channel>Days since last update</channel>"
echo "   <value>${nDaysLastUpdate%%.*}</value>"
echo "   <unit>Custom</unit>"
echo "   <CustomUnit>days</CustomUnit>"
echo "   <LimitMaxError>$DaysAlert</LimitMaxError>"
echo "   <LimitMaxWarning>$DaysWarning</LimitMaxWarning>"
echo "   <LimitMode>1</LimitMode>"

echo -e "</result>\n<result>"

OLDESTPKG=$(while read i ; do 
             curl -I $(yumdownloader --urls -q ${i%% *}) 2>&1 |\
             grep Last-Modified|\
             sed -e 's+Last-Modified: ++'
            done < <(echo "$listPkg4Update"| grep -E ".")| sort -k4,4n -k3,3M -k2,2n| head -n 1)
DAYSSINCE=$(date +"( "%s" - "$(date -d "$OLDESTPKG" +%s)") /60/60/24"|bc -l)
echo "  <channel>Oldest package for update</channel>"
echo "   <value>${DAYSSINCE%%.*}</value>"
echo "   <unit>Custom</unit>"
echo "   <CustomUnit>days</CustomUnit>"
echo "   <LimitMaxError>$DaysWarning</LimitMaxError>"
echo "   <LimitMaxWarning>$DaysNotification</LimitMaxWarning>"

echo -e "</result>\n<result>"

echo "   <channel>Number of pkgs for update</channel>"
echo "   <value>$nPgksUpdate</value>"

echo "</result>"
echo "</prtg>"
