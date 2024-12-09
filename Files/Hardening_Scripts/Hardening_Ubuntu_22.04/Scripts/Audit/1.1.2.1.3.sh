#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.1.3"

# Initialize output variables
l_output=""
l_nosuid_check=""

# Check if /tmp is mounted and verify the nosuid option
l_mount_output=$(findmnt -kn /tmp)

if [[ $l_mount_output == *"/tmp tmpfs"* ]]; then
    # Check if nosuid option is set
    l_nosuid_check=$(echo "$l_mount_output" | grep -v "nosuid")
    
    if [ -z "$l_nosuid_check" ]; then
        l_output+="\n- The nosuid option is correctly set for /tmp."
    else
        l_output+="\n- The nosuid option is NOT set for /tmp."
    fi
else
    l_output+="\n- /tmp is NOT mounted as a separate partition."
fi

# Prepare result report
if [[ -z "$l_nosuid_check" && $l_mount_output == *"/tmp tmpfs"* ]]; then
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
