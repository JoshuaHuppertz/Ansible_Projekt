#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.1.1"

# Initialize output variables
l_output=""
l_mount_output=""
l_systemd_output=""

# Check the mount options for /tmp
l_mount_output=$(findmnt -kn /tmp)
if [[ $l_mount_output == *"/tmp tmpfs"* ]]; then
    l_output+="\n- /tmp is mounted with options: $l_mount_output"
else
    l_output+="\n- /tmp is NOT mounted correctly."
fi

# Check the systemd service for /tmp
l_systemd_output=$(systemctl is-enabled tmp.mount 2>/dev/null)
if [[ $? -ne 0 ]]; then
    l_systemd_output="no-unit-found"
else
    if [[ $l_systemd_output == "generated" || $l_systemd_output == "enabled" ]]; then
        l_output+="\n- systemd service for /tmp is enabled with status: $l_systemd_output"
    else
        l_output+="\n- systemd service for /tmp is NOT enabled or is masked/disabled."
    fi
fi

# Prepare result report
if [[ $l_mount_output == *"/tmp tmpfs"* && ($l_systemd_output == "generated" || $l_systemd_output == "enabled") ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
