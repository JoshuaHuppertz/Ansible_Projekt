#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.3.2"

# Initialize output variables
l_output=""
l_nodev_check=""

# Check if /home has the nodev option set
l_nodev_check=$(findmnt -kn /home | grep -v 'nodev')

# Check if the nodev option is set correctly
if [ -z "$l_nodev_check" ]; then
    l_output+="\n- The nodev option is set for /home."
else
    l_output+="\n- The nodev option is NOT set for /home."
fi

# Prepare result report
if [ -z "$l_nodev_check" ]; then
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
