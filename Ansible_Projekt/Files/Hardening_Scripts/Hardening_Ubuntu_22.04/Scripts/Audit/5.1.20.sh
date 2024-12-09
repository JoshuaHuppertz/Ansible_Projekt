#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.20"

# Initialize output variables
l_output=""
l_output2=""

# Function to check PermitRootLogin
CHECK_PERMIT_ROOT_LOGIN() {
    local permit_root_login_output
    permit_root_login_output=$(sshd -T 2>/dev/null | grep permitrootlogin)

    if [[ $permit_root_login_output == *"no"* ]]; then
        l_output+="\n- PermitRootLogin is correctly set to no."
    else
        l_output2+="\n- PermitRootLogin is not set to no. Current value: ${permit_root_login_output:-not found}."
    fi
}

# Perform the check
CHECK_PERMIT_ROOT_LOGIN

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
