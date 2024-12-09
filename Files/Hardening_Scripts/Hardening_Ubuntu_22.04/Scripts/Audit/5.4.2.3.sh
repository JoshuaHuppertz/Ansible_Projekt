#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.2.3"

# Initialize output variable
output=""

# Command to check if only the group 'root' has GID 0
CHECK_GID_0_GROUP() {
    output=$(awk -F: '($3 == "0") {print $1":"$3}' /etc/group)
}

# Run the check
CHECK_GID_0_GROUP

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [[ "$output" == "root:0" || -z "$output" ]]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- Only the 'root' group has GID 0."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- The following groups have GID 0:\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
