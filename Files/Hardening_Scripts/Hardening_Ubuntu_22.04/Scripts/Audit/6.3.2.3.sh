#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.2.3"

# Initialize result variables
l_output=""
l_output2=""

# Check if disk_full_action is set to halt or single
l_disk_full_action_output=$(sudo grep -Pi '^\s*disk_full_action\s*=\s*(halt|single)\b' /etc/audit/auditd.conf)

if [ -n "$l_disk_full_action_output" ]; then
    l_output+="\n- The 'disk_full_action' parameter is correctly set: $l_disk_full_action_output."
else
    l_output2+="\n- The 'disk_full_action' parameter is not set or is misconfigured (it should be set to halt or single)."
fi

# Check if disk_error_action is set to syslog, single, or halt
l_disk_error_action_output=$(sudo grep -Pi '^\s*disk_error_action\s*=\s*(syslog|single|halt)\b' /etc/audit/auditd.conf)

if [ -n "$l_disk_error_action_output" ]; then
    l_output+="\n- The 'disk_error_action' parameter is correctly set: $l_disk_error_action_output."
else
    l_output2+="\n- The 'disk_error_action' parameter is not set or is misconfigured (it should be set to syslog, single, or halt)."
fi

# Check results and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
