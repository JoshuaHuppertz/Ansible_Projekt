#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.2.8"

# Initialize output variable
output=""

# Function to check enforce_for_root settings
CHECK_ENFORCE_FOR_ROOT() {
    # Check enforce_for_root setting in pwquality.conf and any .conf files in pwquality.conf.d
    enforce_check=$(grep -Psi -- '^\h*enforce_for_root\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf)

    # Prepare output based on checks
    if [ -n "$enforce_check" ]; then
        output+="Found enforce_for_root setting in pwquality configuration files:\n$enforce_check\n"
    else
        output+="No enforce_for_root setting found in pwquality configuration files (as expected).\n"
    fi
}

# Perform the check
CHECK_ENFORCE_FOR_ROOT

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "No enforce_for_root setting found"; then
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
