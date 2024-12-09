#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.2.7"

# Initialize output variable
output=""

# Function to check enforcing settings
CHECK_ENFORCING() {
    # Check enforcing setting in pwquality.conf and any .conf files in pwquality.conf.d
    enforcing_check=$(grep -PHsi -- '^\h*enforcing\h*=\h*0\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf)

    # Check pam_pwquality.so for enforcing setting being overridden
    pam_enforcing_check=$(grep -PHsi -- '^\h*password\h+[^#\n\r]+\h+pam_pwquality\.so\h+([^#\n\r]+\h+)?enforcing=0\b' /etc/pam.d/common-password)

    # Prepare output based on checks
    if [ -n "$enforcing_check" ]; then
        output+="Found enforcing setting set to 0 in pwquality configuration files:\n$enforcing_check\n"
    else
        output+="No enforcing setting found set to 0 in pwquality configuration files (as expected).\n"
    fi

    if [ -n "$pam_enforcing_check" ]; then
        output+="Found incorrect enforcing configuration set to 0 in /etc/pam.d/common-password:\n$pam_enforcing_check\n"
    else
        output+="The pam_pwquality.so arguments are correctly set (nothing returned) in /etc/pam.d/common-password.\n"
    fi
}

# Perform the check
CHECK_ENFORCING

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "Found enforcing setting set to 0"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
elif echo "$output" | grep -q "Found incorrect enforcing configuration"; then
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
