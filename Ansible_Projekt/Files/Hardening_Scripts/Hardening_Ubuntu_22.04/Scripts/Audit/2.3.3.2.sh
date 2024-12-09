#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.3.3.2"

# Initialize output variable
l_output=""

# Check if chronyd is running as _chrony user
if ps -ef | awk '(/[c]hronyd/ && $1!="_chrony") { print $1 }' | read -r; then
    l_output="- chronyd is running as a user other than _chrony."
else
    l_output="- chronyd is correctly running as the _chrony user."
fi

# Prepare the result report
RESULT=""

if [[ -z "$l_output" || "$l_output" == *"correctly"* ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n $l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reason: $l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"