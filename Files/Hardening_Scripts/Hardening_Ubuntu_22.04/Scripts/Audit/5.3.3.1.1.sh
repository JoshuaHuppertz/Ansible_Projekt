#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.1.1"

# Initialize output variable
output=""

# Function to check the number of failed login attempts
CHECK_FAILED_LOGIN_ATTEMPTS() {
    # Check the deny value in faillock.conf
    deny_value=$(grep -Pi -- '^\h*deny\h*=\h*[1-5]\b' /etc/security/faillock.conf)

    # Check if deny is not set, or is 5 or less in common-auth
    deny_check=$(grep -Pi -- '^\h*auth\h+(requisite|required|sufficient)\h+pam_faillock\.so\h+([^#\n\r]+\h+)?deny\h*=\h*(0|[6-9]|[1-9][0-9]+)\b' /etc/pam.d/common-auth)

    # Prepare output based on checks
    if [ -n "$deny_value" ]; then
        output+="Found deny value in /etc/security/faillock.conf:\n$deny_value\n"
    else
        output+="deny argument is not set or is greater than 5 in /etc/security/faillock.conf.\n"
    fi

    if [ -z "$deny_check" ]; then
        output+="The deny argument is correctly set in /etc/pam.d/common-auth (nothing returned).\n"
    else
        output+="Found incorrect deny configuration in /etc/pam.d/common-auth:\n$deny_check\n"
    fi
}

# Perform the check
CHECK_FAILED_LOGIN_ATTEMPTS

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "deny argument is not set or is greater than 5"; then
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
