#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.2.1"

# Initialize output variables
l_output=""
l_shm_check=""

# Check if /dev/shm is mounted
l_mount_output=$(findmnt -kn /dev/shm)

if [[ $l_mount_output == *"/dev/shm tmpfs"* ]]; then
    # If mounted, output the mount options
    l_output+="\n- /dev/shm is mounted with options: $l_mount_output"
else
    l_output+="\n- /dev/shm is NOT mounted."
fi

# Prepare result report
if [[ $l_mount_output == *"/dev/shm tmpfs"* ]]; then
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
