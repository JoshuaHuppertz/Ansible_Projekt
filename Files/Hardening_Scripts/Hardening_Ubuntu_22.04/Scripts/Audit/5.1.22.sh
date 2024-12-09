#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.1.22"

# Initialize output variables
l_output=""
l_output2=""

# Function to check UsePAM
CHECK_USE_PAM() {
    local use_pam_output
    use_pam_output=$(sshd -T 2>/dev/null | grep -i usepam)

    if [[ $use_pam_output == *"yes"* ]]; then
        l_output+="\n- UsePAM is correctly set to yes."
    else
        l_output2+="\n- UsePAM is not set to yes. Current value: ${use_pam_output:-not found}."
    fi
}

# Perform the check
CHECK_USE_PAM

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
