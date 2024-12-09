#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.2.1.1.1"

# Initialize result variables
l_output=""
l_output2=""

# Check if systemd-journald is enabled
enabled_status=$(systemctl is-enabled systemd-journald.service 2>/dev/null)
if [[ "$enabled_status" == "static" ]]; then
    l_output="systemd-journald is enabled: $enabled_status"
else
    l_output2="systemd-journald is not static or enabled: $enabled_status"
fi

# Check if systemd-journald is active
active_status=$(systemctl is-active systemd-journald.service 2>/dev/null)
if [[ "$active_status" == "active" ]]; then
    l_output="$l_output\nsystemd-journald is active: $active_status"
else
    l_output2="$l_output2\nsystemd-journald is not active: $active_status"
fi

# Check results and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- * Correctly Configured * :$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for Failure * :$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- * Correctly Configured * :\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
