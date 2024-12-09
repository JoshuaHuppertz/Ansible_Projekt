#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.4.3"

# Initialize output variable
output=""

# Function to check password hashing algorithm
CHECK_HASHING_ALGORITHM() {
    # Check for pam_unix.so settings with sha512 or yescrypt
    hash_check=$(grep -PH -- '^\h*password\h+[^#\n\r]+\h+pam_unix\.so\h+([^#\n\r]+\h+)?(sha512|yescrypt)\b' /etc/pam.d/common-password)

    # Prepare output based on checks
    if [ -n "$hash_check" ]; then
        output+="Found strong password hashing algorithm:\n$hash_check\n"
    else
        output+="No strong password hashing algorithm found (requires sha512 or yescrypt).\n"
    fi
}

# Perform the check
CHECK_HASHING_ALGORITHM

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "No strong password hashing algorithm found"; then
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
