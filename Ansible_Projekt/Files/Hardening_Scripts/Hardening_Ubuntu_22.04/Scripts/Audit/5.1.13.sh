#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.13"

# Initialize output variables
l_output=""
l_output2=""

# Function to check LoginGraceTime
CHECK_LOGIN_GRACE_TIME() {
    local grace_time_output
    grace_time_output=$(sshd -T 2>/dev/null | grep logingracetime)

    # Check if output is not empty
    if [ -n "$grace_time_output" ]; then
        local grace_time_value
        grace_time_value=$(echo "$grace_time_output" | awk '{print $2}')

        # Validate that the grace time is between 1 and 60 seconds
        if [[ "$grace_time_value" -ge 1 && "$grace_time_value" -le 60 ]]; then
            l_output+="\n- LoginGraceTime is correctly configured to $grace_time_value seconds."
        else
            l_output2+="\n- Invalid LoginGraceTime: $grace_time_value seconds (should be between 1 and 60 seconds)."
        fi
    else
        l_output2+="\n- LoginGraceTime not found in SSHD configuration."
    fi
}

# Perform the check
CHECK_LOGIN_GRACE_TIME

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
