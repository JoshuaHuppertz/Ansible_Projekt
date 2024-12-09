#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.7"

# Initialize output variables
l_output=""
l_output2=""

# Function to check ClientAlive settings
CHECK_CLIENT_ALIVE() {
    local client_alive_output
    client_alive_output=$(sshd -T 2>/dev/null | grep -Pi -- '(clientaliveinterval|clientalivecountmax)')

    # Check if output is not empty
    if [ -n "$client_alive_output" ]; then
        # Loop through the output lines
        while read -r line; do
            key=$(echo "$line" | awk '{print $1}')
            value=$(echo "$line" | awk '{print $2}')

            # Validate the values
            if [[ "$key" == "clientaliveinterval" && "$value" -le 0 ]]; then
                l_output2+="\n- clientaliveinterval should be greater than 0, found: $value"
            elif [[ "$key" == "clientalivecountmax" && "$value" -le 0 ]]; then
                l_output2+="\n- clientalivecountmax should be greater than 0, found: $value"
            fi
        done <<< "$client_alive_output"
    else
        l_output+="\n- No ClientAlive settings found in SSHD configuration."
    fi
}

# Perform the check
CHECK_CLIENT_ALIVE

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure * :$l_output2"
    [ -n "$l_output" ] && RESULT+="\n\n - * Additional findings * :$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
