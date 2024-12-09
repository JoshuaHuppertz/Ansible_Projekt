#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.2.1"

# Initialize output variables
output=""

# Function to check for pam_unix in PAM config files
CHECK_PAM_UNIX() {
    # Check if pam_unix is enabled in PAM configuration files
    output=$(grep -P -- '\bpam_unix\.so\b' /etc/pam.d/common-{account,session,auth,password} 2>/dev/null)

    if [ -n "$output" ]; then
        output="Found pam_unix in the following files:\n$output"
    else
        output="pam_unix is not enabled in the PAM configuration files."
    fi
}

# Perform the check
CHECK_PAM_UNIX

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "Found pam_unix"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
