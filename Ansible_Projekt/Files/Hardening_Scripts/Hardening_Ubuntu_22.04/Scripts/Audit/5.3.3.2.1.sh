#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.2.1"

# Initialize output variable
output=""

# Function to check difok configuration
CHECK_DIFOK() {
    # Check for difok value in pwquality.conf and any .conf files in pwquality.conf.d
    difok_value=$(grep -Psi -- '^\h*difok\h*=\h*([2-9]|[1-9][0-9]+)\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf)

    # Check pam_pwquality.so for difok argument set to 0 or 1
    pam_difok_check=$(grep -Psi -- '^\h*password\h+(requisite|required|sufficient)\h+pam_pwquality\.so\h+([^#\n\r]+\h+)?difok\h*=\h*([0-1])\b' /etc/pam.d/common-password)

    # Prepare output based on checks
    if [ -n "$difok_value" ]; then
        output+="Found difok value(s) in /etc/security/pwquality.conf or .conf files:\n$difok_value\n"
    else
        output+="difok option is not set to 2 or more in /etc/security/pwquality.conf or .conf files.\n"
    fi

    if [ -n "$pam_difok_check" ]; then
        output+="Found incorrect difok configuration in /etc/pam.d/common-password:\n$pam_difok_check\n"
    else
        output+="The difok argument is correctly set (nothing returned) in /etc/pam.d/common-password.\n"
    fi
}

# Perform the check
CHECK_DIFOK

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "difok option is not set to 2 or more"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
elif echo "$output" | grep -q "Found incorrect difok configuration"; then
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