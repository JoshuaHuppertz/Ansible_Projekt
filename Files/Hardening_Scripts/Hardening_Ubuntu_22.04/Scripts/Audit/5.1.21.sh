#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.21"

# Initialize output variables
l_output=""
l_output2=""

# Function to check PermitUserEnvironment
CHECK_PERMIT_USER_ENVIRONMENT() {
    local permit_user_environment_output
    permit_user_environment_output=$(sshd -T 2>/dev/null | grep permituserenvironment)

    if [[ $permit_user_environment_output == *"no"* ]]; then
        l_output+="\n- PermitUserEnvironment is correctly set to no."
    else
        l_output2+="\n- PermitUserEnvironment is not set to no. Current value: ${permit_user_environment_output:-not found}."
    fi
}

# Perform the check
CHECK_PERMIT_USER_ENVIRONMENT

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
