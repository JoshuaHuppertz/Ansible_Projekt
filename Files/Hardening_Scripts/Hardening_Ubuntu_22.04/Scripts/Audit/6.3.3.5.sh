#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.3.5"

# Initialize result variables
l_output=""
l_output2=""

# Expected on-disk rules
expected_on_disk_rules="\
-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale
-a always,exit -F arch=b32 -S sethostname,setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/network -p wa -k system-locale
-w /etc/netplan -p wa -k system-locale"

# Check On-Disk configuration
on_disk_rules=$(awk '/^ *-a *always,exit/ && / -F *arch=b(32|64)/ && / -S/ && (/sethostname/ || /setdomainname/) && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules 2>/dev/null)
file_rules=$(awk '/^ *-w/ && (/\/etc\/issue/ || /\/etc\/issue.net/ || /\/etc\/hosts/ || /\/etc\/network/ || /\/etc\/netplan/) && / -p *wa/ && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules 2>/dev/null)

# Compare on-disk rules
if [[ "$on_disk_rules" == *"$expected_on_disk_rules"* && "$file_rules" == *"$expected_on_disk_rules"* ]]; then
    l_output+="\n- On-Disk rules are correctly configured:\n$on_disk_rules\n$file_rules"
else
    l_output2+="\n- Error in On-Disk rules:\n$on_disk_rules\n$file_rules"
    l_output2+="\n- Expected on-disk rules:\n$expected_on_disk_rules\n"
fi

# Check Running configuration
running_rules=$(sudo auditctl -l | awk '/^ *-a *always,exit/ && / -F *arch=b(32|64)/ && / -S/ && (/sethostname/ || /setdomainname/) && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' 2>/dev/null)
running_file_rules=$(sudo auditctl -l | awk '/^ *-w/ && (/\/etc\/issue/ || /\/etc\/issue.net/ || /\/etc\/hosts/ || /\/etc\/network/ || /\/etc\/netplan/) && / -p *wa/ && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' 2>/dev/null)

# Compare running rules
if [[ "$running_rules" == *"-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale"* && "$running_file_rules" == *"-w /etc/issue -p wa -k system-locale"* ]]; then
    l_output+="\n- Running rules are correctly configured:\n$running_rules\n$running_file_rules"
else
    l_output2+="\n- Error in Running rules:\n$running_rules\n"
    l_output2+="\n- Expected running rules:\n$expected_on_disk_rules\n"
fi

# Check and output result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
