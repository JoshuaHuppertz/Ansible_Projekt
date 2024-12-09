#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.5"

# Initialize output variables
l_output=""
l_output2=""

# Function to check SSHD banner configuration
CHECK_BANNER_CONFIG() {
    local config_output
    config_output=$(sshd -T 2>/dev/null | grep -Pi -- '^banner\h+\/\H+')

    if [ -n "$config_output" ]; then
        l_output+="\n- Banner configuration found:\n$config_output\n"
    else
        l_output+="\n- No banner configuration found in SSHD settings.\n"
    fi
}

# Function to check Match block configurations
CHECK_MATCH_BLOCK() {
    local match_user="sshuser"  # Change this to the desired user for the match test
    local match_output
    match_output=$(sshd -T -C user=$match_user 2>/dev/null | grep -Pi -- '^banner\h+\/\H+')

    if [ -n "$match_output" ]; then
        l_output+="\n- Additional check for Match block for user: $match_user\n"
        l_output+="\n- Banner configuration in Match block found:\n$match_output\n"
    else
        l_output+="\n- No banner configuration found in Match block for user $match_user.\n"
    fi
}

# Perform the checks
CHECK_BANNER_CONFIG
CHECK_MATCH_BLOCK

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$l_output" | grep -q 'No banner configuration'; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
