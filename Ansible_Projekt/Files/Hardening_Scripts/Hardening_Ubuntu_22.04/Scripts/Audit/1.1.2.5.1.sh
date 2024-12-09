#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.5.1"

# Initialize output variable
l_output=""

# Check if /var/tmp is mounted
l_var_tmp_check=$(findmnt -kn /var/tmp)

# Verify if /var/tmp is mounted
if [ -n "$l_var_tmp_check" ]; then
    l_output+="\n- /var/tmp is mounted: $l_var_tmp_check"
else
    l_output+="\n- /var/tmp is NOT mounted."
fi

# Prepare result report
if [ -n "$l_var_tmp_check" ]; then
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
