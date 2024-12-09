#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.2.3"

# Initialize output variable
output=""

# Function to check for pam_pwquality in the common-password PAM config file
CHECK_PAM_PWQUALITY() {
    # Check if pam_pwquality is enabled in the common-password file
    output=$(grep -P -- '\bpam_pwquality\.so\b' /etc/pam.d/common-password 2>/dev/null)

    if [ -n "$output" ]; then
        output="Found pam_pwquality in /etc/pam.d/common-password:\n$output"
    else
        output="pam_pwquality is not enabled in /etc/pam.d/common-password."
    fi
}

# Perform the check
CHECK_PAM_PWQUALITY

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "Found pam_pwquality"; then
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
