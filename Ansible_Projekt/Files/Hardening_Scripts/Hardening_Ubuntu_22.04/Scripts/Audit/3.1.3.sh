#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="3.1.3"

# Check if bluez package is installed
if dpkg-query -s bluez &>/dev/null; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- bluez is installed\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- bluez is not installed\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# If bluez package is required, check the bluetooth service
if [ "$RESULT" == *"PASS"* ]; then
    # Check if bluetooth.service is enabled
    if systemctl is-enabled bluetooth.service 2>/dev/null | grep -q 'enabled'; then
        RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- bluetooth.service is enabled\n"
        FILE_NAME="$RESULT_DIR/fail.txt"
    fi

    # Check if bluetooth.service is active
    if systemctl is-active bluetooth.service 2>/dev/null | grep -q '^active'; then
        RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- bluetooth.service is active\n"
        FILE_NAME="$RESULT_DIR/fail.txt"
    fi
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
