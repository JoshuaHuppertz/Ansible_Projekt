#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.2.1.1"

# Initialize output variable
l_output=""
l_gpg_keys_check=""

# Run the command to list GPG keys
l_gpg_keys_check=$(apt-key list 2>&1)

# Check if there are GPG keys configured
if echo "$l_gpg_keys_check" | grep -q 'pub'; then
    l_output+="\n- GPG keys are configured correctly for the package manager."
else
    l_output+="\n- No GPG keys found for the package manager. Configuration may be incorrect."
fi

# Prepare result report
if [[ "$l_output" == *"No GPG keys found for the package manager."* ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
