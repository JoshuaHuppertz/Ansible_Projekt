#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.2.3"

# Initialize output variable
output=""

# Function to check password complexity settings
CHECK_COMPLEXITY() {
    # Check complexity settings in pwquality.conf and any .conf files in pwquality.conf.d
    complexity_settings=$(grep -Psi -- '^\h*(minclass|[dulo]credit)\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf)

    # Check pam_pwquality.so for complexity settings being overridden
    pam_complexity_check=$(grep -Psi -- '^\h*password\h+(requisite|required|sufficient)\h+pam_pwquality\.so\h+([^#\n\r]+\h+)?(minclass=\d*|[dulo]credit=-?\d*)\b' /etc/pam.d/common-password)

    # Prepare output based on checks
    if [ -n "$complexity_settings" ]; then
        output+="Found complexity settings in /etc/security/pwquality.conf or .conf files:\n$complexity_settings\n"
    else
        output+="Complexity settings not found in /etc/security/pwquality.conf or .conf files.\n"
    fi

    if [ -n "$pam_complexity_check" ]; then
        output+="Found incorrect complexity configuration in /etc/pam.d/common-password:\n$pam_complexity_check\n"
    else
        output+="The pam_pwquality.so arguments are correctly set (nothing returned) in /etc/pam.d/common-password.\n"
    fi
}

# Perform the check
CHECK_COMPLEXITY

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "Complexity settings not found"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
elif echo "$output" | grep -q "Found incorrect complexity configuration"; then
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
