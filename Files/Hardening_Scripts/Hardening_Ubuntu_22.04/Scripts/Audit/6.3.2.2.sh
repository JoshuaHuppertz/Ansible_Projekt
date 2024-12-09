#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.2.2"

# Initialize result variables
l_output=""
l_output2=""

# Check if max_log_file_action is correctly set in auditd.conf
l_log_file_action_output=$(sudo grep -P '^\s*max_log_file_action\s*=\s*keep_logs' /etc/audit/auditd.conf)

if [ -n "$l_log_file_action_output" ]; then
    l_output+="\n- The 'max_log_file_action' parameter is correctly set: $l_log_file_action_output."
else
    l_output2+="\n- The 'max_log_file_action' parameter is not set or is misconfigured."
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
