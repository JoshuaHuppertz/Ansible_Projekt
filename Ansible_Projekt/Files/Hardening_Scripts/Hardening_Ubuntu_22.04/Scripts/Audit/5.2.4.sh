#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.2.4"

# Initialize output variables
l_output=""
l_output2=""

# Function to check for NOPASSWD entries in sudoers files
CHECK_NOPASSWD() {
    # Check for any NOPASSWD entries in /etc/sudoers and /etc/sudoers.d/*
    # Redirect grep errors to /dev/null to suppress "Permission denied" messages
    NOPASSWD_LINES=$(sudo grep -r "^[^#].*NOPASSWD" /etc/sudoers* 2>/dev/null)

    if [ -n "$NOPASSWD_LINES" ]; then
        l_output2+="\n- NOPASSWD entries found in the sudoers configuration:\n$NOPASSWD_LINES"
    else
        l_output+="\n- No NOPASSWD entries found."
    fi
}

# Perform the check
CHECK_NOPASSWD

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
