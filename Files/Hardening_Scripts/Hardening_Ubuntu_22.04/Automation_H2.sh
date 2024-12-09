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
echo "H2: Audit is running on $(hostname) with IP $HOST_IP" > $PASS_FILE
date >> $PASS_FILE
echo "-------------------------------------------------" >> $PASS_FILE
echo "H2: Audit is running on $(hostname) with IP $HOST_IP" > $FAIL_FILE
date >> $FAIL_FILE
echo "-------------------------------------------------" >> $FAIL_FILE
sleep 2.5
#clear




echo "Audit für Härtegrad 2 ausgewählt."
# 1.1 Filesystem
# 1.1.1 Configure Filesystem Kernel Modules
bash "$HARDENING_Audit/1.1.1.6.sh" #Level.2 Server
bash "$HARDENING_Audit/1.1.1.7.sh" #Level.2 Server
# 1.1.2 Configure Filesystem Partitions
# 1.1.2.3.1 Configure /home
bash "$HARDENING_Audit/1.1.2.3.1.sh" #Level.2 Server
# 1.1.2.4.1 Configure /var
bash "$HARDENING_Audit/1.1.2.4.1.sh" #Level.2 Server
# 1.1.2.5.1 Configure /var/tmp
bash "$HARDENING_Audit/1.1.2.5.1.sh" #Level.2 Server
# 1.1.2.6.1 Configure /var/log
bash "$HARDENING_Audit/1.1.2.6.1.sh" #Level.2 Server
# 1.1.2.7.1 Configure /var/log/audit
bash "$HARDENING_Audit/1.1.2.7.1.sh" #Level.2 Server
# 1.3 Mandatory Access Control
# 1.3.1 Configure AppArmor
bash "$HARDENING_Audit/1.3.1.4.sh" #Level.2 Server
# 1.7 Configure GNOME Display Manager
bash "$HARDENING_Audit/1.7.1.sh" #Level.2 Server
bash "$HARDENING_Audit/1.7.6.sh" #Level.2 Workstation
bash "$HARDENING_Audit/1.7.7.sh" #Level.2 Workstation
# 2.1 Configure Server Services
bash "$HARDENING_Audit/2.1.1.sh" #Level.2 Workstation
bash "$HARDENING_Audit/2.1.2.sh" #Level.2 Workstation
bash "$HARDENING_Audit/2.1.11.sh" #Level.2 Workstation
bash "$HARDENING_Audit/2.1.20.sh" #Level.2 Server
# 3.1 Configure Network Devices
bash "$HARDENING_Audit/3.1.3.sh" #Level.2 Workstation
# 3.2 Configure Network Kernel Modules
bash "$HARDENING_Audit/3.2.1.sh"  #Level.2
bash "$HARDENING_Audit/3.2.2.sh"  #Level.2
bash "$HARDENING_Audit/3.2.3.sh"  #Level.2
bash "$HARDENING_Audit/3.2.4.sh"  #Level.2
# 5.1 Configure SSH Server
bash "$HARDENING_Audit/5.1.8.sh" #Level.2 Server
bash "$HARDENING_Audit/5.1.9.sh" #Level.2 Server
# 5.2 Configure privilege escalation
bash "$HARDENING_Audit/5.2.4.sh" #Level.2
# 5.3 Pluggable Authentication Modules
# 5.3.3 Configure PAM Arguments
# 5.3.3.1 Configure pam_faillock module
bash "$HARDENING_Audit/5.3.3.1.3.sh" #Level.2
# 5.4 User Accounts and Environment
# 5.4.1 Configure shadow password suite parameters
bash "$HARDENING_Audit/5.4.1.2.sh" #Manual Level.2
# 5.4.3 Configure user default environmen
bash "$HARDENING_Audit/5.4.3.1.sh" #Level.2 
# 6.1 Configure Filesystem Integrity Checking
bash "$HARDENING_Audit/6.1.3.sh" #Level.2
# 6.3 System Auditing
# 6.3.1 Configure auditd Service
bash "$HARDENING_Audit/6.3.1.1.sh" #Level.2
bash "$HARDENING_Audit/6.3.1.2.sh" #Level.2
bash "$HARDENING_Audit/6.3.1.3.sh" #Level.2
bash "$HARDENING_Audit/6.3.1.4.sh" #Level.2
# 6.3.2 Configure Data Retention
bash "$HARDENING_Audit/6.3.2.1.sh" #Level.2
bash "$HARDENING_Audit/6.3.2.2.sh" #Level.2
bash "$HARDENING_Audit/6.3.2.3.sh" #Level.2
bash "$HARDENING_Audit/6.3.2.4.sh" #Level.2
# 6.3.3 Configure auditd Rules
bash "$HARDENING_Audit/6.3.3.1.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.2.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.3.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.4.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.5.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.6.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.7.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.8.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.9.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.10.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.11.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.12.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.13.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.14.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.15.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.16.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.17.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.18.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.19.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.20.sh" #Level.2
bash "$HARDENING_Audit/6.3.3.21.sh" #Manual Level.2
# 6.3.4 Configure auditd File Access
bash "$HARDENING_Audit/6.3.4.1.sh" #Level.2
bash "$HARDENING_Audit/6.3.4.2.sh" #Level.2
bash "$HARDENING_Audit/6.3.4.3.sh" #Level.2
bash "$HARDENING_Audit/6.3.4.5.sh" #Level.2
bash "$HARDENING_Audit/6.3.4.6.sh" #Level.2
bash "$HARDENING_Audit/6.3.4.7.sh" #Level.2
bash "$HARDENING_Audit/6.3.4.8.sh" #Level.2
bash "$HARDENING_Audit/6.3.4.9.sh" #Level.2
bash "$HARDENING_Audit/6.3.4.10.sh" #Level.2
        
