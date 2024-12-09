#!/bin/bash

#/Hardening
#│
#└── Hardening_Ubuntu_22.04
#    ├── Automation.sh
#    ├── Results
#    │   ├── pass.txt
#    │   └── fail.txt
#    └── Scripts
#        ├── Audit
#        └── Remediation


# Pfad zu den Härtungsskripten
HARDENING_Audit="./Scripts/Audit"
PASS_FILE="./Results/pass.txt"
FAIL_FILE="./Results/fail.txt"

# Get the IP address of the host
HOST_IP=$(hostname -I | awk '{print $1}')
echo "H1: Audit is running on $(hostname) with IP $HOST_IP" > $PASS_FILE
date >> $PASS_FILE
echo "-------------------------------------------------" >> $PASS_FILE
echo "H1: Audit is running on $(hostname) with IP $HOST_IP" > $FAIL_FILE
date >> $FAIL_FILE
echo "-------------------------------------------------" >> $FAIL_FILE
sleep 2.5
#clear




echo "Audit für Härtegrad 1 ausgewählt."
# 1.1 Filesystem
# 1.1.1 Configure Filesystem Kernel Modules
bash "$HARDENING_Audit/1.1.1.1.sh"
bash "$HARDENING_Audit/1.1.1.2.sh"
bash "$HARDENING_Audit/1.1.1.3.sh"
bash "$HARDENING_Audit/1.1.1.4.sh"
bash "$HARDENING_Audit/1.1.1.5.sh"
bash "$HARDENING_Audit/1.1.1.8.sh"
# 1.1.2 Configure Filesystem Partitions
# 1.1.2.1 Configure /tmp
#
bash "$HARDENING_Audit/1.1.2.1.1.sh"
bash "$HARDENING_Audit/1.1.2.1.2.sh"
bash "$HARDENING_Audit/1.1.2.1.3.sh"
bash "$HARDENING_Audit/1.1.2.1.4.sh"
# 1.1.2.2.1 Configure /dev/shm
bash "$HARDENING_Audit/1.1.2.2.1.sh"
bash "$HARDENING_Audit/1.1.2.2.2.sh"
bash "$HARDENING_Audit/1.1.2.2.3.sh"
bash "$HARDENING_Audit/1.1.2.2.4.sh"
# 1.1.2.3.1 Configure /home
bash "$HARDENING_Audit/1.1.2.3.2.sh"
bash "$HARDENING_Audit/1.1.2.3.3.sh"
# 1.1.2.4.1 Configure /var
bash "$HARDENING_Audit/1.1.2.4.2.sh"
bash "$HARDENING_Audit/1.1.2.4.3.sh"
# 1.1.2.5.1 Configure /var/tmp
bash "$HARDENING_Audit/1.1.2.5.2.sh"
bash "$HARDENING_Audit/1.1.2.5.3.sh"
bash "$HARDENING_Audit/1.1.2.5.4.sh"
# 1.1.2.6.1 Configure /var/log
bash "$HARDENING_Audit/1.1.2.6.2.sh"
bash "$HARDENING_Audit/1.1.2.6.3.sh"
bash "$HARDENING_Audit/1.1.2.6.4.sh"
# 1.1.2.7.1 Configure /var/log/audit
bash "$HARDENING_Audit/1.1.2.7.2.sh"
bash "$HARDENING_Audit/1.1.2.7.3.sh"
bash "$HARDENING_Audit/1.1.2.7.4.sh"
# 1.2 Package Management
# 1.2.1 Configure Package Repositories
bash "$HARDENING_Audit/1.2.1.1.sh" #Manual
bash "$HARDENING_Audit/1.2.1.2.sh" #Manual
# 1.2.2 Configure Package Updates
bash "$HARDENING_Audit/1.2.2.1.sh" #Manual
# 1.3 Mandatory Access Control
# 1.3.1 Configure AppArmor
bash "$HARDENING_Audit/1.3.1.1.sh"
bash "$HARDENING_Audit/1.3.1.2.sh"
bash "$HARDENING_Audit/1.3.1.3.sh"
# 1.4 Configure Bootloader
bash "$HARDENING_Audit/1.4.1_Manual.sh"
bash "$HARDENING_Audit/1.4.2.sh"
# 1.5 Configure Additional Process Hardening
bash "$HARDENING_Audit/1.5.1.sh"
bash "$HARDENING_Audit/1.5.2.sh"
bash "$HARDENING_Audit/1.5.3.sh"
bash "$HARDENING_Audit/1.5.4.sh"
bash "$HARDENING_Audit/1.5.5.sh"
# 1.6  Configure Command Line Warning Banners
bash "$HARDENING_Audit/1.6.1.sh"
bash "$HARDENING_Audit/1.6.2.sh"
bash "$HARDENING_Audit/1.6.3.sh"
bash "$HARDENING_Audit/1.6.4.sh"
bash "$HARDENING_Audit/1.6.5.sh"
bash "$HARDENING_Audit/1.6.6.sh"
# 1.7 Configure GNOME Display Manager
bash "$HARDENING_Audit/1.7.2.sh"
bash "$HARDENING_Audit/1.7.3.sh"
bash "$HARDENING_Audit/1.7.4.sh"
bash "$HARDENING_Audit/1.7.5.sh"
bash "$HARDENING_Audit/1.7.8.sh"
bash "$HARDENING_Audit/1.7.9.sh"
bash "$HARDENING_Audit/1.7.10.sh"
#
# 2.1 Configure Server Services
bash "$HARDENING_Audit/2.1.3.sh"
bash "$HARDENING_Audit/2.1.4.sh"
bash "$HARDENING_Audit/2.1.5.sh"
bash "$HARDENING_Audit/2.1.6.sh"
bash "$HARDENING_Audit/2.1.7.sh"
bash "$HARDENING_Audit/2.1.8.sh"
bash "$HARDENING_Audit/2.1.9.sh"
bash "$HARDENING_Audit/2.1.10.sh"
bash "$HARDENING_Audit/2.1.12.sh"
bash "$HARDENING_Audit/2.1.13.sh"
bash "$HARDENING_Audit/2.1.14.sh"
bash "$HARDENING_Audit/2.1.15.sh"
bash "$HARDENING_Audit/2.1.16.sh"
bash "$HARDENING_Audit/2.1.17.sh"
bash "$HARDENING_Audit/2.1.18.sh"
bash "$HARDENING_Audit/2.1.19.sh"
bash "$HARDENING_Audit/2.1.21_Manual.sh"
bash "$HARDENING_Audit/2.1.22.sh" #Manual
# 2.2  Configure Client Services
bash "$HARDENING_Audit/2.2.1.sh"
bash "$HARDENING_Audit/2.2.2.sh"
bash "$HARDENING_Audit/2.2.3.sh"
bash "$HARDENING_Audit/2.2.4.sh"
bash "$HARDENING_Audit/2.2.5.sh"
bash "$HARDENING_Audit/2.2.6.sh"
# 2.3 Configure Time Synchronization
# 2.3.1 Ensure time synchronization is in use
bash "$HARDENING_Audit/2.3.1.1.sh"
# 2.3.2 Configure systemd-timesyncd
bash "$HARDENING_Audit/2.3.2.1.sh"
bash "$HARDENING_Audit/2.3.2.2.sh" #Manual
# 2.3.3 Configure chrony
bash "$HARDENING_Audit/2.3.3.1.sh" #Manual
bash "$HARDENING_Audit/2.3.3.2.sh"
bash "$HARDENING_Audit/2.3.3.3.sh"
# 2.4 Job Schedulers
# 2.4.1 Configure cron
bash "$HARDENING_Audit/2.4.1.1.sh"
bash "$HARDENING_Audit/2.4.1.2.sh"
bash "$HARDENING_Audit/2.4.1.3.sh"
bash "$HARDENING_Audit/2.4.1.4.sh"
bash "$HARDENING_Audit/2.4.1.5.sh"
bash "$HARDENING_Audit/2.4.1.6.sh"
bash "$HARDENING_Audit/2.4.1.7.sh"
bash "$HARDENING_Audit/2.4.1.8.sh"
# 2.4.2 Configure at
bash "$HARDENING_Audit/2.4.2.1.sh"
#
# 3.1 Configure Network Devices
bash "$HARDENING_Audit/3.1.1.sh"  #Manual
bash "$HARDENING_Audit/3.1.2.sh"
# 3.3 Configure Network Kernel Parameters
bash "$HARDENING_Audit/3.3.1.sh"
bash "$HARDENING_Audit/3.3.2.sh"
bash "$HARDENING_Audit/3.3.3.sh"
bash "$HARDENING_Audit/3.3.4.sh"
bash "$HARDENING_Audit/3.3.5.sh"
bash "$HARDENING_Audit/3.3.6.sh"
bash "$HARDENING_Audit/3.3.7.sh"
bash "$HARDENING_Audit/3.3.8.sh"
bash "$HARDENING_Audit/3.3.9.sh"
bash "$HARDENING_Audit/3.3.10.sh"
bash "$HARDENING_Audit/3.3.11.sh"
#
# 4.1 Configure UncomplicatedFirewall
bash "$HARDENING_Audit/4.1.1.sh"
bash "$HARDENING_Audit/4.1.2.sh"
bash "$HARDENING_Audit/4.1.3.sh"
bash "$HARDENING_Audit/4.1.4_Manual.sh"
bash "$HARDENING_Audit/4.1.5_Manual.sh"  #Manual
bash "$HARDENING_Audit/4.1.6.sh"
bash "$HARDENING_Audit/4.1.7.sh"
# 4.2 Configure nftables
bash "$HARDENING_Audit/4.2.1.sh"
bash "$HARDENING_Audit/4.2.2.sh"
bash "$HARDENING_Audit/4.2.3.sh" #Manual
bash "$HARDENING_Audit/4.2.4.sh"
bash "$HARDENING_Audit/4.2.5.sh"
bash "$HARDENING_Audit/4.2.6.sh"
bash "$HARDENING_Audit/4.2.7_Manual.sh" #Manual
bash "$HARDENING_Audit/4.2.8.sh"
bash "$HARDENING_Audit/4.2.9.sh"
bash "$HARDENING_Audit/4.2.10.sh"
# 4.3 Configure iptables
# 4.3.1 Configure iptables software
bash "$HARDENING_Audit/4.3.1.1.sh"
bash "$HARDENING_Audit/4.3.1.2.sh"
bash "$HARDENING_Audit/4.3.1.3.sh"
# 4.3.2 Configure IPv4 iptables
bash "$HARDENING_Audit/4.3.2.1.sh"
bash "$HARDENING_Audit/4.3.2.2_Manual.sh"
bash "$HARDENING_Audit/4.3.2.3_Manual.sh" #Manual
bash "$HARDENING_Audit/4.3.2.4.sh"
# 4.3.3 Configure IPv6 ip6tables
bash "$HARDENING_Audit/4.3.3.1.sh"
bash "$HARDENING_Audit/4.3.3.2.sh"
bash "$HARDENING_Audit/4.3.3.3.sh" #Manual
bash "$HARDENING_Audit/4.3.3.4.sh"
#
# 5.1 Configure SSH Server
bash "$HARDENING_Audit/5.1.1.sh"
bash "$HARDENING_Audit/5.1.2.sh"
bash "$HARDENING_Audit/5.1.3.sh"
bash "$HARDENING_Audit/5.1.4.sh"
bash "$HARDENING_Audit/5.1.5.sh"
bash "$HARDENING_Audit/5.1.6.sh"
bash "$HARDENING_Audit/5.1.7.sh"
bash "$HARDENING_Audit/5.1.10.sh"
bash "$HARDENING_Audit/5.1.11.sh"
bash "$HARDENING_Audit/5.1.12.sh"
bash "$HARDENING_Audit/5.1.13.sh"
bash "$HARDENING_Audit/5.1.14.sh"
bash "$HARDENING_Audit/5.1.15.sh"
bash "$HARDENING_Audit/5.1.16.sh"
bash "$HARDENING_Audit/5.1.17.sh"
bash "$HARDENING_Audit/5.1.18.sh"
bash "$HARDENING_Audit/5.1.19.sh"
bash "$HARDENING_Audit/5.1.20.sh"
bash "$HARDENING_Audit/5.1.21.sh"
bash "$HARDENING_Audit/5.1.22.sh"
# 5.2 Configure privilege escalation
bash "$HARDENING_Audit/5.2.1.sh"
bash "$HARDENING_Audit/5.2.2.sh"
bash "$HARDENING_Audit/5.2.3.sh"
bash "$HARDENING_Audit/5.2.5.sh"
bash "$HARDENING_Audit/5.2.6.sh"
bash "$HARDENING_Audit/5.2.7_Manual.sh"
# 5.3 Pluggable Authentication Modules
# 5.3.1 Configure PAM software packages
bash "$HARDENING_Audit/5.3.1.1.sh"
bash "$HARDENING_Audit/5.3.1.2.sh"
bash "$HARDENING_Audit/5.3.1.3.sh"
# 5.3.2 Configure pam-auth-update profiles
bash "$HARDENING_Audit/5.3.2.1.sh"
bash "$HARDENING_Audit/5.3.2.2.sh"
bash "$HARDENING_Audit/5.3.2.3.sh"
bash "$HARDENING_Audit/5.3.2.4.sh"
# 5.3.3 Configure PAM Arguments
# 5.3.3.1 Configure pam_faillock module
bash "$HARDENING_Audit/5.3.3.1.1.sh"
bash "$HARDENING_Audit/5.3.3.1.2.sh"
# 5.3.3.2 Configure pam_pwquality module
bash "$HARDENING_Audit/5.3.3.2.1.sh"
bash "$HARDENING_Audit/5.3.3.2.2.sh"
bash "$HARDENING_Audit/5.3.3.2.3.sh" #Manual
bash "$HARDENING_Audit/5.3.3.2.4.sh"
bash "$HARDENING_Audit/5.3.3.2.5.sh"
bash "$HARDENING_Audit/5.3.3.2.6.sh"
bash "$HARDENING_Audit/5.3.3.2.7.sh"
bash "$HARDENING_Audit/5.3.3.2.8.sh"
# 5.3.3.3 Configure pam_pwhistory module
bash "$HARDENING_Audit/5.3.3.3.1.sh"
bash "$HARDENING_Audit/5.3.3.3.2.sh"
bash "$HARDENING_Audit/5.3.3.3.3.sh"
# 5.3.3.4 Configure pam_unix module
bash "$HARDENING_Audit/5.3.3.4.1.sh"
bash "$HARDENING_Audit/5.3.3.4.2.sh"
bash "$HARDENING_Audit/5.3.3.4.3.sh"
bash "$HARDENING_Audit/5.3.3.4.4.sh"
# 5.4 User Accounts and Environment
# 5.4.1 Configure shadow password suite parameters
bash "$HARDENING_Audit/5.4.1.1.sh"
bash "$HARDENING_Audit/5.4.1.3.sh"
bash "$HARDENING_Audit/5.4.1.4.sh"
bash "$HARDENING_Audit/5.4.1.5.sh"
bash "$HARDENING_Audit/5.4.1.6.sh"
# 5.4.2 Configure root and system accounts and environment
bash "$HARDENING_Audit/5.4.2.1.sh"
bash "$HARDENING_Audit/5.4.2.2.sh"
bash "$HARDENING_Audit/5.4.2.3.sh"
bash "$HARDENING_Audit/5.4.2.4.sh"
bash "$HARDENING_Audit/5.4.2.5.sh"
bash "$HARDENING_Audit/5.4.2.6.sh"
bash "$HARDENING_Audit/5.4.2.7.sh"
bash "$HARDENING_Audit/5.4.2.8.sh"
# 5.4.3 Configure user default environmen
bash "$HARDENING_Audit/5.4.3.2.sh"
bash "$HARDENING_Audit/5.4.3.3.sh"
#
# 6.1 Configure Filesystem Integrity Checking
bash "$HARDENING_Audit/6.1.1.sh"
bash "$HARDENING_Audit/6.1.2.sh"
# 6.2 System Logging
# 6.2.1 Configure journald
# 6.2.1.1 Configure systemd-journald service
bash "$HARDENING_Audit/6.2.1.1.1.sh"
bash "$HARDENING_Audit/6.2.1.1.2.sh" #Manual
bash "$HARDENING_Audit/6.2.1.1.3.sh" #Manual
bash "$HARDENING_Audit/6.2.1.1.4.sh"
bash "$HARDENING_Audit/6.2.1.1.5.sh"
bash "$HARDENING_Audit/6.2.1.1.6.sh"
# 6.2.1.2 Configure systemd-journal-remote
bash "$HARDENING_Audit/6.2.1.2.1.sh"
bash "$HARDENING_Audit/6.2.1.2.2.sh" #Manual
bash "$HARDENING_Audit/6.2.1.2.3.sh"
bash "$HARDENING_Audit/6.2.1.2.4.sh"
# 6.2.2 Configure Logfiles
bash "$HARDENING_Audit/6.2.2.1.sh"
#
# 7.1 System File Permissions
bash "$HARDENING_Audit/7.1.1.sh"
bash "$HARDENING_Audit/7.1.2.sh"
bash "$HARDENING_Audit/7.1.3.sh"
bash "$HARDENING_Audit/7.1.4.sh"
bash "$HARDENING_Audit/7.1.5.sh"
bash "$HARDENING_Audit/7.1.6.sh"
bash "$HARDENING_Audit/7.1.7.sh"
bash "$HARDENING_Audit/7.1.8.sh"
bash "$HARDENING_Audit/7.1.9.sh"
bash "$HARDENING_Audit/7.1.10.sh"
bash "$HARDENING_Audit/7.1.11.sh"
bash "$HARDENING_Audit/7.1.12.sh"
bash "$HARDENING_Audit/7.1.13.sh"  #Manual
# 7.2 Local User and Group Settings
bash "$HARDENING_Audit/7.2.1.sh"
bash "$HARDENING_Audit/7.2.2.sh"
bash "$HARDENING_Audit/7.2.3.sh"
bash "$HARDENING_Audit/7.2.4.sh"
bash "$HARDENING_Audit/7.2.5.sh"
bash "$HARDENING_Audit/7.2.6.sh"
bash "$HARDENING_Audit/7.2.7.sh"
bash "$HARDENING_Audit/7.2.8.sh"
bash "$HARDENING_Audit/7.2.9.sh"
bash "$HARDENING_Audit/7.2.10.sh"
        
