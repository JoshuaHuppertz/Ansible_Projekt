#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.1.2.5.3"

# Initialize output variable
l_output=""

# Check if /var/tmp is mounted and has nosuid option
l_var_tmp_check=$(findmnt -kn /var/tmp)

# Verify if /var/tmp is mounted
if [ -n "$l_var_tmp_check" ]; then
    # Check for the nosuid option
    if findmnt -kn /var/tmp | grep -q 'nosuid'; then
        l_output+="\n- nosuid option is set for /var/tmp."
    else
        l_output+="\n- nosuid option is NOT set for /var/tmp."
    fi
else
    l_output+="\n- /var/tmp is NOT mounted."
fi

# Prepare result report
if [[ "$l_output" == *"NOT set"* || "$l_output" == *"NOT mounted"* ]]; then
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
