#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.2.4"

# Initialize output variable
output=""

# Command to check if the root user has a password set
CHECK_ROOT_PASSWORD() {
    # Suppress stderr output and only capture the required output
    output=$(passwd -S root 2>/dev/null | awk '$2 ~ /^P/ {print "User: \"" $1 "\" Password is set"}')
}

# Run the check
CHECK_ROOT_PASSWORD

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [[ "$output" == 'User: "root" Password is set' ]]; then
    RESULT="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- Root user's password is set."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Root user's password is not set."
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"