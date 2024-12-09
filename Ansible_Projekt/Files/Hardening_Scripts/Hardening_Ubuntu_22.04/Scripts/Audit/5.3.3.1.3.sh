#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.1.3"

# Initialize output variable
output=""

# Function to check even_deny_root and root_unlock_time configurations
CHECK_ROOT_UNLOCK_TIME() {
    # Check for even_deny_root and root_unlock_time in faillock.conf
    even_deny_root_value=$(grep -Pi -- '^\h*(even_deny_root|root_unlock_time\h*=\h*\d+)\b' /etc/security/faillock.conf)

    # Check if root_unlock_time is set to 60 or more
    root_unlock_time_check=$(grep -Pi -- '^\h*root_unlock_time\h*=\h*([1-9]|[1-5][0-9])\b' /etc/security/faillock.conf)

    # Check pam_faillock.so for root_unlock_time argument
    pam_root_unlock_check=$(grep -Pi -- '^\h*auth\h+([^#\n\r]+\h+)pam_faillock\.so\h+([^#\n\r]+\h+)?root_unlock_time\h*=\h*([1-9]|[1-5][0-9])\b' /etc/pam.d/common-auth)

    # Prepare output based on checks
    if [ -n "$even_deny_root_value" ]; then
        output+="Found even_deny_root and/or root_unlock_time in /etc/security/faillock.conf:\n$even_deny_root_value\n"
    else
        output+="Neither even_deny_root nor root_unlock_time is enabled in /etc/security/faillock.conf.\n"
    fi

    if [ -n "$root_unlock_time_check" ]; then
        output+="Found root_unlock_time value in /etc/security/faillock.conf:\n$root_unlock_time_check\n"
    else
        output+="root_unlock_time is not set or is less than 60 in /etc/security/faillock.conf.\n"
    fi

    if [ -n "$pam_root_unlock_check" ]; then
        output+="Found root_unlock_time configuration in /etc/pam.d/common-auth:\n$pam_root_unlock_check\n"
    else
        output+="root_unlock_time is not set to 60 or more in /etc/pam.d/common-auth (nothing returned).\n"
    fi
}

# Perform the check
CHECK_ROOT_UNLOCK_TIME

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "Neither even_deny_root nor root_unlock_time is enabled"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
elif echo "$output" | grep -q "root_unlock_time is not set or is less than 60"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
elif echo "$output" | grep -q "Found root_unlock_time configuration"; then
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
