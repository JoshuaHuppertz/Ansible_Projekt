#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.14"

# Initialize output variables
l_output=""
l_output2=""

# Function to check LogLevel
CHECK_LOG_LEVEL() {
    local log_level_output
    log_level_output=$(sshd -T 2>/dev/null | grep loglevel)

    # Check if output is not empty
    if [ -n "$log_level_output" ]; then
        local log_level_value
        log_level_value=$(echo "$log_level_output" | awk '{print $2}')

        # Validate that the log level is VERBOSE or INFO
        if [[ "$log_level_value" == "VERBOSE" || "$log_level_value" == "INFO" ]]; then
            l_output+="\n- LogLevel is correctly configured to $log_level_value."
        else
            l_output2+="\n- Invalid LogLevel: $log_level_value (should be VERBOSE or INFO)."
        fi
    else
        l_output2+="\n- LogLevel not found in SSHD configuration."
    fi
}

# Perform the check
CHECK_LOG_LEVEL

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
