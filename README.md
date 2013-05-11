openvpn-iptables
================

Simple scripts to manage iptables rules based on user CCD files. 
Feel free to use and modify the scripts as you like. 

## INSTALL

1) copy the scripts to the OpenVPN server, make them executable (chmod +x on_*.sh)
2) Define them in the config:

> script-security 2
>
> client-connect /etc/openvpn/on_connect.sh
>
> client-disconnect /etc/openvpn/on_disconnect.sh

3) configure sudo for the OpenVPN user. This was tested under CentOS, where OpenVPN is run under the user "nobody":

create a file /etc/sudoers.d/openvpn_iptables with the following contents

> Defaults:nobody !requiretty
> 
> nobody ALL = NOPASSWD: /sbin/iptables

this will allow the user "nobody" to run "sudo iptables" without a password

Under Debian, OpenVPN is run as root, so sudo directives can be removed alltogether from both scripts.

4) (Centos/RHEL/Fedora only): configure SELinux to allow iptables execution 
    a) disable enforcement temporarily:
        `setenforce 0`
    b) connect and disconnect a client, verify the log and run "iptables-save" to verify that rules are added and removed.
    c) convert audit logs to the new policy:
        `grep openvpn /var/log/audit/audit.log | audit2allow -M openvpn_sudo_ipt`
    d) install the policy
        `semodule -i openvpn_sudo_ipt.pp`
    e) enable enforcement back:
        `setenforce 1`

## TROUBLESHOOTING

The scripts have seen only limited testing. If something doesn't work, first try running them manually as root. 
They rely on env variables `common_name` and `ifconfig_pool_remote_ip` which are normally sent by openvpn.

To test, first export the variables:
> export common_name=jekader
>
> export ifconfig_pool_remote_ip=1.2.3.4

Now ensure that a CCD file with routes is present and the path is defined correctly in the script.
After running the on_connect.sh script, iptables should appear, as well as log entries.

## TODO

*parse iroute directives
*rethink file locking

## License
The scripts are in the Public Domain
