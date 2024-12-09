#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.12"

# Initialize output variables
l_output=""
l_output2=""

# Function to check for weak Key Exchange algorithms
CHECK_WEAK_KEX_ALGORITHMS() {
    local kex_output
    kex_output=$(sshd -T 2>/dev/null | grep -Pi -- 'kexalgorithms')

    # Check if output is not empty
    if [ -n "$kex_output" ]; then
        # Check for weak algorithms
        if [[ "$kex_output" =~ (diffie-hellman-group1-sha1|diffie-hellman-group14-sha1|diffie-hellman-group-exchange-sha1) ]]; then
            l_output2+="\n- Weak Key Exchange algorithms found: $kex_output"
        fi
    else
        l_output+="\n- No Key Exchange algorithms found in SSHD configuration."
    fi
}

# Perform the check
CHECK_WEAK_KEX_ALGORITHMS

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
