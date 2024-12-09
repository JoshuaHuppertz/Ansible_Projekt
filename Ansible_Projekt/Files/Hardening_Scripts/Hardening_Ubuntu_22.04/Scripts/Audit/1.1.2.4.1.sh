#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.4.1"

# Initialize output variables
l_output=""
l_var_check=""

# Check if /var is mounted
l_var_check=$(findmnt -kn /var)

# Check if the output shows /var is mounted
if [ -n "$l_var_check" ]; then
    l_output+="\n- /var is mounted: $l_var_check"
else
    l_output+="\n- /var is NOT mounted."
fi

# Prepare result report
if [ -n "$l_var_check" ]; then
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
