#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.4.4"

# Initialize output variable
output=""

# Function to check use_authtok setting
CHECK_USE_AUTHTOK() {
    # Check for pam_unix.so settings with use_authtok
    authtok_check=$(grep -PH -- '^\h*password\h+[^#\n\r]+\h+pam_unix\.so\h+([^#\n\r]+\h+)?use_authtok\b' /etc/pam.d/common-password)

    # Prepare output based on checks
    if [ -n "$authtok_check" ]; then
        output+="Found use_authtok setting:\n$authtok_check\n"
    else
        output+="No use_authtok setting found on pam_unix.so module lines.\n"
    fi
}

# Perform the check
CHECK_USE_AUTHTOK

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "No use_authtok setting found"; then
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
