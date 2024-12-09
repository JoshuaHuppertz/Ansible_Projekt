#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.2.2"

# Initialize output variable
output=""

# Command to check if only root and specific system users have GID 0
CHECK_GID_0_USERS() {
    output=$(awk -F: '($1 !~ /^(sync|shutdown|halt|operator)/ && $4 == "0") { print $1":"$4 }' /etc/passwd)
}

# Run the check
CHECK_GID_0_USERS

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [[ "$output" == "root:0" || -z "$output" ]]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- Only 'root' and allowed system users have GID 0."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- The following users have GID 0:\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
