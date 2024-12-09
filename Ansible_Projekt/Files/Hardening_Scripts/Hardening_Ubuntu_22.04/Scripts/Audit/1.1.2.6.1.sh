#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.6.1"

# Initialize output variable
l_output=""

# Check if /var/log is mounted
l_var_log_check=$(findmnt -kn /var/log)

# Verify if /var/log is mounted
if [ -n "$l_var_log_check" ]; then
    l_output+="\n- /var/log is mounted: $l_var_log_check"
else
    l_output+="\n- /var/log is NOT mounted."
fi

# Prepare result report
if [[ "$l_output" == *"NOT mounted"* ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
