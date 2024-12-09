#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.4.2"

# Initialize output variables
l_output=""
l_var_check=""

# Check if /var is mounted and has the nodev option
l_var_check=$(findmnt -kn /var | grep -v 'nodev')

# Check if any output was returned from the grep command
if [ -z "$l_var_check" ]; then
    l_output+="\n- The nodev option is set for /var."
else
    l_output+="\n- The nodev option is NOT set for /var."
fi

# Prepare result report
if [ -z "$l_var_check" ]; then
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
