#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.2.6"

# Initialize output variables
l_output=""
timeout_value=""
is_default=true  # Flag to check if the default value is used

# Function to check timestamp_timeout in sudoers files
CHECK_TIMESTAMP_TIMEOUT() {
    # Check for timestamp_timeout values
    if timeout_value=$(sudo grep -roP "timestamp_timeout=\K[0-9]*" /etc/sudoers*); then
        if [ "$timeout_value" ]; then
            # Check if the value is greater than 15
            if (( timeout_value > 15 )); then
                l_output+="\n- timestamp_timeout is set to $timeout_value minutes, which is greater than 15 minutes."
            else
                l_output+="\n- timestamp_timeout is set to $timeout_value minutes."
            fi
            is_default=false  # We found a specific configuration
        fi
    fi

    # If no specific configuration found, check the default value
    if $is_default; then
        timeout_value=$(sudo -V | sudo grep "Authentication timestamp timeout:" | awk '{print $NF}')
        if [ "$timeout_value" = "-1" ]; then
            l_output+="\n- timestamp_timeout is disabled (set to -1)."
        elif (( timeout_value > 15 )); then
            l_output+="\n- Default timestamp_timeout is set to $timeout_value minutes, which is greater than 15 minutes."
        else
            l_output+="\n- Default timestamp_timeout is set to $timeout_value minutes."
        fi
    fi
}

# Perform the check
CHECK_TIMESTAMP_TIMEOUT

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [[ $l_output == *"greater than 15 minutes."* ]]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure * :$l_output"
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
