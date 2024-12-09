#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.1.3"

# Initialize output variables
l_output=""
l_output2=""

# Expected rules
expected_rules=(
    "Anywhere on lo ALLOW IN Anywhere"
    "Anywhere DENY IN 127.0.0.0/8"
    "Anywhere (v6) on lo ALLOW IN Anywhere (v6)"
    "Anywhere (v6) DENY IN ::1"
    "Anywhere ALLOW OUT Anywhere on lo"
    "Anywhere (v6) ALLOW OUT Anywhere (v6) on lo"
)

# Get the current UFW status verbose output
ufw_status_output=$(ufw status verbose)

# Check each expected rule
for rule in "${expected_rules[@]}"; do
    if grep -q "$rule" <<< "$ufw_status_output"; then
        l_output="$l_output\n- Rule \"$rule\" is correctly set"
    else
        l_output2="$l_output2\n- Rule \"$rule\" is missing or incorrect"
    fi
done

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Correctly set:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
