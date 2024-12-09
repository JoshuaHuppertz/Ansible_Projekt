#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.2.4"

# Initialize output variables
l_output=""
l_noexec_check=""

# Check if /dev/shm is mounted with noexec option
l_mount_options=$(findmnt -kn /dev/shm | grep -v 'noexec')

if [ -z "$l_mount_options" ]; then
    l_output+="\n- /dev/shm is mounted with the noexec option set."
else
    l_output+="\n- /dev/shm is NOT mounted with the noexec option set. Output: $l_mount_options"
fi

# Prepare result report
if [ -z "$l_mount_options" ]; then
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
