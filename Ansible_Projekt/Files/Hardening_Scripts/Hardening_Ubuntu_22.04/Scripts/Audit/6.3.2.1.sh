#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.2.1"

# Initialize result variables
l_output=""
l_output2=""

# Check if max_log_file is set in auditd.conf
l_log_file_output=$(sudo grep -Po -- '^\h*max_log_file\h*=\h*\d+\b' /etc/audit/auditd.conf)

if [ -n "$l_log_file_output" ]; then
    l_output+="\n- The 'max_log_file' parameter is set: $l_log_file_output."
else
    l_output2+="\n- The 'max_log_file' parameter is not set or is incorrectly configured."
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
