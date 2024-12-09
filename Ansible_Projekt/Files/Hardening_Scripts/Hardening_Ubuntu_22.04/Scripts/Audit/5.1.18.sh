#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.18"

# Initialize output variables
l_output=""
l_output2=""

# Function to check MaxStartups
CHECK_MAX_STARTUPS() {
    local startup_output
    startup_output=$(sshd -T 2>/dev/null | awk '$1 ~ /^\s*maxstartups/{print $2}')

    if [ -n "$startup_output" ]; then
        # Split the MaxStartups value into its components
        IFS=: read -r max_conn max_wait max_users <<< "$startup_output"

        # Check if values exceed the limits
        if [ "$max_conn" -gt 10 ] || [ "$max_wait" -gt 30 ] || [ "$max_users" -gt 60 ]; then
            l_output2+="\n- MaxStartups is set to $startup_output, which exceeds the limits of 10:30:60."
        else
            l_output+="\n- MaxStartups is correctly set to $startup_output."
        fi
    else
        l_output2+="\n- MaxStartups setting not found."
    fi
}

# Perform the check
CHECK_MAX_STARTUPS

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
