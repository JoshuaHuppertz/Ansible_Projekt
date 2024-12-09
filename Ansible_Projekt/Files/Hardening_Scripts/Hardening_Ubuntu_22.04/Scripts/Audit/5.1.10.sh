#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.10"

# Initialize output variables
l_output=""
l_output2=""

# Function to check HostbasedAuthentication setting
CHECK_HOSTBASED_AUTHENTICATION() {
    local hostbased_auth_output
    hostbased_auth_output=$(sshd -T 2>/dev/null | grep hostbasedauthentication)

    # Check if output is not empty
    if [ -n "$hostbased_auth_output" ]; then
        # Check if HostbasedAuthentication is set to no
        if [[ "$hostbased_auth_output" != *"hostbasedauthentication no"* ]]; then
            l_output2+="\n- HostbasedAuthentication should be set to no, found: $hostbased_auth_output"
        fi
    else
        l_output+="\n- No HostbasedAuthentication setting found in SSHD configuration."
    fi
}

# Perform the check
CHECK_HOSTBASED_AUTHENTICATION

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
