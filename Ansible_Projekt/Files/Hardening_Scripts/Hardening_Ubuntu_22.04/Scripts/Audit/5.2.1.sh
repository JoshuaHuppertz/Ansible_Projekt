#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.2.1"

# Initialize output variables
l_output=""
l_output2=""

# Function to check for sudo and sudo-ldap installation
CHECK_SUDO_INSTALLATION() {
    if dpkg-query -s sudo &>/dev/null; then
        l_output+="\n- sudo is installed."
    elif dpkg-query -s sudo-ldap &>/dev/null; then
        l_output+="\n- sudo-ldap is installed."
    else
        l_output2+="\n- Neither sudo nor sudo-ldap is installed."
    fi
}

# Perform the check
CHECK_SUDO_INSTALLATION

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for audit failure * :$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
