#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.3.2.2"

# Initialize output variable
output=""

# Function to check minlen configuration
CHECK_MINLEN() {
    # Check for minlen value in pwquality.conf and any .conf files in pwquality.conf.d
    minlen_value=$(grep -Psi -- '^\h*minlen\h*=\h*(1[4-9]|[2-9][0-9]|[1-9][0-9]{2,})\b' /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf)

    # Check pam_pwquality.so for minlen argument set to less than 14
    pam_minlen_check=$(grep -Psi -- '^\h*password\h+(requisite|required|sufficient)\h+pam_pwquality\.so\h+([^#\n\r]+\h+)?minlen\h*=\h*([0-9]|1[0-3])\b' /etc/pam.d/system-auth /etc/pam.d/common-password)

    # Prepare output based on checks
    if [ -n "$minlen_value" ]; then
        output+="Found minlen value(s) in /etc/security/pwquality.conf or .conf files:\n$minlen_value\n"
    else
        output+="minlen option is not set to 14 or more in /etc/security/pwquality.conf or .conf files.\n"
    fi

    if [ -n "$pam_minlen_check" ]; then
        output+="Found incorrect minlen configuration in /etc/pam.d/system-auth or /etc/pam.d/common-password:\n$pam_minlen_check\n"
    else
        output+="The minlen argument is correctly set (nothing returned) in /etc/pam.d/system-auth and /etc/pam.d/common-password.\n"
    fi
}

# Perform the check
CHECK_MINLEN

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "minlen option is not set to 14 or more"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
elif echo "$output" | grep -q "Found incorrect minlen configuration"; then
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
