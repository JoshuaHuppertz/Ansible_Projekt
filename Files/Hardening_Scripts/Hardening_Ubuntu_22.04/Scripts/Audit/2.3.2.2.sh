#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.3.2.2"

# Initialize output variables
l_output=""
l_output2=""

# Check if systemd-timesyncd is active
if systemctl is-active --quiet systemd-timesyncd.service; then
    # Check if systemd-timesyncd is enabled
    if systemctl is-enabled --quiet systemd-timesyncd.service; then
        l_output="- systemd-timesyncd.service is enabled and active."
        RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
        FILE_NAME="$RESULT_DIR/pass.txt"
    else
        l_output2="- systemd-timesyncd.service is not enabled."
        RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reason: $l_output2\n"
        FILE_NAME="$RESULT_DIR/fail.txt"
    fi
else
    l_output2="systemd-timesyncd.service is not active."
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reason: $l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
