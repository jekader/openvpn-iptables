#!/bin/bash                                                                                                                                                                                                                                  
# a script that adds iptables rules according to routes sent to the client. 
# Iptables FORWARD policy must be "DROP", or a rule must exist to drop all remaining traffic.

#OpenVPN configuration file (gets parsed for global route definitions)
ovpnconfig="/etc/openvpn/server.conf"

#CCD directory for user configs (also present in the config file above but repeated here to make things faster)
ccd="/etc/openvpn/ccd"

logfile="/var/log/openvpn/iptables.log"
date >> $logfile
whoami >> $logfile

#iptables rule comment - the disconnect script will remove all strings matching this pattern
rulecomment=$common_name"_openvpn"

if [ -f $ovpnconfig ]
then
# read file | delete leading spaces         | delete double spaces | delete commented strings|delete quotes| get routes
    cat $ovpnconfig | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/ \+ / /g' | grep -v "^#" | grep -v "^;" | tr -d '"'   | grep "^push route" | while read line; do
        network=$(echo $line | cut -f3 -d" ")
        netmask=$(echo $line | cut -f4 -d" ")
        echo "iptables -I FORWARD -s $ifconfig_pool_remote_ip -d $network/$netmask -j ACCEPT -m comment --comment $rulecomment" >> $logfile
        /usr/bin/sudo /sbin/iptables -I FORWARD -s $ifconfig_pool_remote_ip -d $network/$netmask -j ACCEPT -m comment --comment $rulecomment >> $logfile 2>&1
    done
fi
if [ -f $ccd/$common_name ]
then
# read file | delete leading spaces         | delete double spaces | delete commented strings|delete quotes| get routes
    cat $ccd/$common_name | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/ \+ / /g' | grep -v "^#" | grep -v "^;" | tr -d '"'   | grep "^push route" | while read line; do
        network=$(echo $line | cut -f3 -d" ")
        netmask=$(echo $line | cut -f4 -d" ")
        echo "iptables -I FORWARD -s $ifconfig_pool_remote_ip -d $network/$netmask -j ACCEPT -m comment --comment $rulecomment" >> $logfile
        /usr/bin/sudo /sbin/iptables -I FORWARD -s $ifconfig_pool_remote_ip -d $network/$netmask -j ACCEPT -m comment --comment $rulecomment >> $logfile 2>&1
    done
fi
exit 0
