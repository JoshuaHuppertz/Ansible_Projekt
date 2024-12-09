#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.1.2"

# Initialize output variable
output=""

# Function to check the unlock time configuration
CHECK_UNLOCK_TIME() {
    # Check the unlock_time value in faillock.conf
    unlock_time_value=$(grep -Pi -- '^\h*unlock_time\h*=\h*(0|9[0-9][0-9]|[1-9][0-9]{3,})\b' /etc/security/faillock.conf)

    # Check if unlock_time is not set, or is 0 or 900 or more in common-auth
    unlock_time_check=$(grep -Pi -- '^\h*auth\h+(requisite|required|sufficient)\h+pam_faillock\.so\h+([^#\n\r]+\h+)?unlock_time\h*=\h*([1-9]|[1-9][0-9]|[1-8][0-9][0-9])\b' /etc/pam.d/common-auth)

    # Prepare output based on checks
    if [ -n "$unlock_time_value" ]; then
        output+="Found unlock_time value in /etc/security/faillock.conf:\n$unlock_time_value\n"
    else
        output+="unlock_time argument is not set, or is less than 0 or less than 900 in /etc/security/faillock.conf.\n"
    fi

    if [ -z "$unlock_time_check" ]; then
        output+="The unlock_time argument is correctly set in /etc/pam.d/common-auth (nothing returned).\n"
    else
        output+="Found incorrect unlock_time configuration in /etc/pam.d/common-auth:\n$unlock_time_check\n"
    fi
}

# Perform the check
CHECK_UNLOCK_TIME

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "unlock_time argument is not set, or is less than 0 or less than 900"; then
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
#echo -e "$RESULT"
