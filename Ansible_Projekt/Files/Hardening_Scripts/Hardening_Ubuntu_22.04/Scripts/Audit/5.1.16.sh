#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.16"

# Initialize output variables
l_output=""
l_output2=""
max_auth_tries=4

# Function to check MaxAuthTries
CHECK_MAX_AUTH_TRIES() {
    local auth_output
    auth_output=$(sshd -T 2>/dev/null | grep maxauthtries)

    if [ -n "$auth_output" ]; then
        # Extract the value of MaxAuthTries
        local value
        value=$(echo "$auth_output" | awk '{print $2}')

        if [ "$value" -gt "$max_auth_tries" ]; then
            l_output2+="\n- MaxAuthTries is set to $value, which exceeds the limit of $max_auth_tries."
        else
            l_output+="\n- MaxAuthTries is correctly set to $value."
        fi
    else
        l_output2+="\n- MaxAuthTries setting not found."
    fi
}

# Perform the check
CHECK_MAX_AUTH_TRIES

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure * :$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
