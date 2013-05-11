#!/bin/bash
#a scripts that removes rules with a given comment

logfile="/var/log/openvpn/iptables.log"
date >> $logfile
whoami >> $logfile

#make sure the script is run once at a time. 
#This will leave some rules in place, however that's much better than
#having two scripts running simultaneously and screwing up iptables
#
pidfile=/var/lock/openvpn_disconnect.pid
if [ -e $pidfile ]; then
    pid=`cat $pidfile`
    if kill -0 $pid > /dev/null 2>&1; then
        echo "Another script running, aborting rules removal for $common_name" >> $logfile 2>&1
        exit 1
    else
        rm $pidfile
    fi
fi
echo $$ > $pidfile

#the script itself        
rulecomment=$common_name"_openvpn"
#list rules with line numbers            | get needed rules  | sort reverse| remove line by line
/usr/bin/sudo /sbin/iptables -L FORWARD --line-numbers | grep $rulecomment | sort -r -n  | while read line; do
    rulenumber=$(echo $line | cut -f1 -d" ")
    echo "iptables -D FORWARD $rulenumber" >> $logfile 2>&1
    /usr/bin/sudo /sbin/iptables -D FORWARD $rulenumber
done

#remove the PID file after everything is done
rm $pidfile
exit 0
