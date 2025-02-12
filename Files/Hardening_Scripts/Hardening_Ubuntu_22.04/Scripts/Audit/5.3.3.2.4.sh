#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.2.4"

# Initialize output variable
output=""

# Function to check maxrepeat settings
CHECK_MAXREPEAT() {
    # Check maxrepeat setting in pwquality.conf and any .conf files in pwquality.conf.d
    maxrepeat_settings=$(grep -Psi -- '^\h*maxrepeat\h*=\h*[1-3]\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf)

    # Check pam_pwquality.so for maxrepeat setting being overridden
    pam_maxrepeat_check=$(grep -Psi -- '^\h*password\h+(requisite|required|sufficient)\h+pam_pwquality\.so\h+([^#\n\r]+\h+)?maxrepeat\h*=\h*(0|[4-9]|[1-9][0-9]+)\b' /etc/pam.d/common-password)

    # Prepare output based on checks
    if [ -n "$maxrepeat_settings" ]; then
        output+="Found maxrepeat setting in /etc/security/pwquality.conf or .conf files:\n$maxrepeat_settings\n"
    else
        output+="maxrepeat setting not found in /etc/security/pwquality.conf or .conf files.\n"
    fi

    if [ -n "$pam_maxrepeat_check" ]; then
        output+="Found incorrect maxrepeat configuration in /etc/pam.d/common-password:\n$pam_maxrepeat_check\n"
    else
        output+="The pam_pwquality.so arguments are correctly set (nothing returned) in /etc/pam.d/common-password.\n"
    fi
}

# Perform the check
CHECK_MAXREPEAT

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "maxrepeat setting not found"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
elif echo "$output" | grep -q "Found incorrect maxrepeat configuration"; then
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
