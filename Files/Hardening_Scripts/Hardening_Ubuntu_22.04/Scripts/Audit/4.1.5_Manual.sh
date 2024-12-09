#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.1.4"

# Initialize output variables
l_output=""
l_output2=""

# Get the current UFW numbered status
ufw_status_output=$(ufw status numbered)

# Here, we assume there is a placeholder for policy checks or pattern matching.
# For example, if you have specific rules to match, define them in expected_rules and compare.
# This needs to be adjusted to match your specific site policy.
# Example placeholder: let's assume a rule pattern like "ALLOW OUT anywhere"

expected_outbound_policy="ALLOW OUT anywhere"
if grep -q "$expected_outbound_policy" <<< "$ufw_status_output"; then
    l_output="$l_output\n- Outbound rule \"$expected_outbound_policy\" matches site policy"
else
    l_output2="$l_output2\n- Outbound rule \"$expected_outbound_policy\" does not match site policy"
fi

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
