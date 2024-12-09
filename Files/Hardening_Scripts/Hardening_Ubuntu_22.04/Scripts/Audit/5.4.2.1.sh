#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.2.1"

# Initialize output variable
output=""

# Command to find users with UID 0
CHECK_ROOT_UID() {
    output=$(awk -F: '($3 == 0) { print $1 }' /etc/passwd)
}

# Run the check
CHECK_ROOT_UID

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [[ "$output" == "root" ]]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- Only 'root' has UID 0."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\nThe following users have UID 0:\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"