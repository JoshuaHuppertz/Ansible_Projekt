#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.17"

# Initialize output variables
l_output=""
l_output2=""
max_sessions=10

# Function to check MaxSessions
CHECK_MAX_SESSIONS() {
    local session_output
    session_output=$(sshd -T 2>/dev/null | grep -i maxsessions)

    if [ -n "$session_output" ]; then
        # Extract the value of MaxSessions
        local value
        value=$(echo "$session_output" | awk '{print $2}')

        if [ "$value" -gt "$max_sessions" ]; then
            l_output2+="\n- MaxSessions is set to $value, which exceeds the limit of $max_sessions."
        else
            l_output+="\n- MaxSessions is correctly set to $value."
        fi
    else
        l_output2+="\n- MaxSessions setting not found."
    fi

    # Check configuration files for any MaxSessions value greater than 10
    if grep -Psi -- '^\h*MaxSessions\h+\"?(1[1-9]|[2-9][0-9]|[1-9][0-9][0-9]+)\b' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf; then
        l_output2+="\n- A MaxSessions value greater than 10 was found in the configuration files."
    fi
}

# Perform the check
CHECK_MAX_SESSIONS

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
