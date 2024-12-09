#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.3.4"

# Initialize result variables
l_output=""
l_output2=""

# Check On-Disk configuration
on_disk_rules=$(sudo awk '/^ *-a *always,exit/ \ && / -F *arch=b(32|64)/ \ && / -S/ \ && (/adjtimex/ || /settimeofday/ || /clock_settime/) \ && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules 2>/dev/null)

localtime_rule=$(sudo awk '/^ *-w/ && /\/etc\/localtime/ && / -p *wa/ && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules 2>/dev/null)


expected_on_disk_rules="\
-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change
-w /etc/localtime -p wa -k time-change"

if [[ "$on_disk_rules" == *"$expected_on_disk_rules"* && "$localtime_rule" == *"$expected_on_disk_rules"* ]]; then
    l_output+="\n- On-Disk rules are correctly configured:\n$on_disk_rules\n$localtime_rule"
else
    l_output2+="\n- Error in On-Disk rules:\n$on_disk_rules\n$localtime_rule"  
    l_output2+="\n- Expected on-disk rules:\n$expected_on_disk_rules\n"
fi

# Check Running configuration
running_rules=$(sudo auditctl -l | awk '/^ *-a *always,exit/ && / -F *arch=b(32|64)/ && / -S/ && (/adjtimex/ || /settimeofday/ || /clock_settime/) && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' 2>/dev/null)


running_localtime_rule=$(sudo auditctl -l | awk '/^ *-w/ && /\/etc\/localtime/ && / -p *wa/ && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' 2>/dev/null)


if [[ "$running_rules" == *"-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change"* && \
      "$running_localtime_rule" == *"-w /etc/localtime -p wa -k time-change"* ]]; then
    l_output+="\n- Running rules are correctly configured:\n$running_rules\n$running_localtime_rule"
else
    l_output2+="\n- Error in Running rules:\n$running_rules"
    l_output2+="\n- Expected running rules:\n$expected_on_disk_rules"
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
