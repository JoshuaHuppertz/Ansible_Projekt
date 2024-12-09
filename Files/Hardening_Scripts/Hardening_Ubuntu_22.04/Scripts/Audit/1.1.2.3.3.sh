#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.3.3"

# Initialize output variables
l_output=""
l_nosuid_check=""

# Check if /home has the nosuid option set
l_nosuid_check=$(findmnt -kn /home | grep -v 'nosuid')

# Check if the nosuid option is set correctly
if [ -z "$l_nosuid_check" ]; then
    l_output+="\n- The nosuid option is set for /home."
else
    l_output+="\n- The nosuid option is NOT set for /home."
fi

# Prepare result report
if [ -z "$l_nosuid_check" ]; then
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
