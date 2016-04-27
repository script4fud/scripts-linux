#!/bin/bash

## This shell script performs a relatively deep cleanup of various RHEL/Centos
## system files.  This can be run before creating a clone or image to prevent
## inadvertant data leakage.
## From: https://lonesysadmin.net/2013/03/26/preparing-linux-template-vms/

# Stop logging services
/sbin/service rsyslog stop
/sbin/service auditd stop

# Remove old kernels
/usr/bin/package-cleanup --oldkernels --count=1

# Clean Yum
/usr/bin/yum clean all

# Force log rotation & purge old logs
/usr/sbin/logrotate -f /etc/logrotate.conf
/bin/rm -f /var/log/*-???????? /var/log/*.gz
/bin/rm -f /var/log/dmesg.old
/bin/rm -rf /var/log/anaconda

# Truncate the audit logs (and other logs for which we want to keep placeholders)
/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/grubby

# Remove the udev persistent device rules
/bin/rm -f /etc/udev/rules.d/70*

# Remove the traces of the template MAC address and UUIDs
/bin/sed -i '/^(HWADDR|UUID)=/d' /etc/sysconfig/network-scripts/ifcfg-eth0

# Clean /tmp directories
/bin/rm -rf /tmp/*
/bin/rm -rf /var/tmp/*

# Remove the SSH host keys
/bin/rm -f /etc/ssh/*key*

# Remove the root user’s shell history, SSH history & other cruft
/bin/rm -f ~root/.bash_history
unset HISTFILE
/bin/rm -rf ~root/.ssh/
/bin/rm -f ~root/anaconda-ks.cfg

# Remove other users' shell history, SSH history, & other cruft
for user in $(ls /home);
do
	echo Cleaning up user $user
	sudo /bin/rm -f /home/$user/.bash_history
	sudo /bin/rm -rf /home/$user/.ssh/
  sudo /bin/rm -f /home/$user/anaconda-ks.cfg
done

# Cleanup reporting mail & recreate blank file for root user
/bin/rm -rf /var/spool/mail/*
sudo touch /var/spool/mail/root

# Restart logging services
/sbin/service rsyslog start
/sbin/service auditd start
