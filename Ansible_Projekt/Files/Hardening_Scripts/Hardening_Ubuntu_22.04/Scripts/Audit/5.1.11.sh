#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.11"

# Initialize output variables
l_output=""
l_output2=""

# Function to check IgnoreRhosts setting
CHECK_IGNORE_RHOSTS() {
    local ignore_rhosts_output
    ignore_rhosts_output=$(sshd -T 2>/dev/null | grep ignorerhosts)

    # Check if output is not empty
    if [ -n "$ignore_rhosts_output" ]; then
        # Check if IgnoreRhosts is set to yes
        if [[ "$ignore_rhosts_output" != *"ignorerhosts yes"* ]]; then
            l_output2+="\n- IgnoreRhosts should be set to yes, found: $ignore_rhosts_output"
        fi
    else
        l_output+="\n- No IgnoreRhosts setting found in SSHD configuration."
    fi
}

# Perform the check
CHECK_IGNORE_RHOSTS

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
