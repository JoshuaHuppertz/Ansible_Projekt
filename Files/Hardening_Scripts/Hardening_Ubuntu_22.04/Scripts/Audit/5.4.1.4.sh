#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.1.4"

# Initialize output variable
output=""

# Function to check ENCRYPT_METHOD in /etc/login.defs
CHECK_ENCRYPT_METHOD_LOGIN_DEFS() {
    encrypt_method_check=$(grep -Pi -- '^\h*ENCRYPT_METHOD\h+(SHA512|yescrypt)\b' /etc/login.defs)
    
    if [[ "$encrypt_method_check" =~ (SHA512|YESCRYPT) ]]; then
        method_value="${BASH_REMATCH[1]}"
        output+="ENCRYPT_METHOD in /etc/login.defs is set to: $method_value (PASS)\n"
    else
        output+="ENCRYPT_METHOD is not set to SHA512 or YESCRYPT in /etc/login.defs (FAIL)\n"
    fi
}

# Perform the check
CHECK_ENCRYPT_METHOD_LOGIN_DEFS

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "(FAIL)"; then
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
