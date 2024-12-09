#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.3.1"

# Initialize output variable
output=""

# Function to check pwhistory settings
CHECK_PWHISTORY() {
    # Check remember value in common-password
    pwhistory_check=$(grep -Psi -- '^\h*password\h+[^#\n\r]+\h+pam_pwhistory\.so\h+([^#\n\r]+\h+)?remember=\d+\b' /etc/pam.d/common-password)

    # Prepare output based on checks
    if [ -n "$pwhistory_check" ]; then
        # Extract the remember value
        remember_value=$(echo "$pwhistory_check" | grep -oP 'remember=\K\d+')
        
        if [ "$remember_value" -ge 24 ]; then
            output+="Found remember setting: $pwhistory_check\n"
            output+="Remember value is $remember_value (meets local site policy).\n"
        else
            output+="Found remember setting: $pwhistory_check\n"
            output+="Remember value is $remember_value (does NOT meet local site policy).\n"
        fi
    else
        output+="No pwhistory setting found in common-password (as expected).\n"
    fi
}

# Perform the check
CHECK_PWHISTORY

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "does NOT meet local site policy"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$output"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"

# Optionally print the result to the console
#echo -e "$RESULT"
