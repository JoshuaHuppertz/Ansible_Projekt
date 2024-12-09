#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.8"

# Initialize output variables
l_output=""
l_output2=""

# Function to check DisableForwarding setting
CHECK_DISABLE_FORWARDING() {
    local disable_forwarding_output
    disable_forwarding_output=$(sshd -T 2>/dev/null | grep -i disableforwarding)

    # Check if output is not empty
    if [ -n "$disable_forwarding_output" ]; then
        # Check if DisableForwarding is set to yes
        if [[ "$disable_forwarding_output" != *"disableforwarding yes"* ]]; then
            l_output2+="\n- DisableForwarding should be set to yes, found: $disable_forwarding_output"
        fi
    else
        l_output+="\n- No DisableForwarding setting found in SSHD configuration."
    fi
}

# Perform the check
CHECK_DISABLE_FORWARDING

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure * :$l_output2"
    [ -n "$l_output" ] && RESULT+="\n\n- * Additional findings * :$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
