#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.2.1.2"

# Initialize output variable
l_output=""
l_repo_check=""

# Run the command to check package repositories
l_repo_check=$(apt-cache policy 2>&1)

# Check if the output contains valid repository information
if echo "$l_repo_check" | grep -q 'http\|deb\|distro'; then
    l_output+="\n- Package repositories are configured correctly."
else
    l_output+="\n- No valid package repositories found. Configuration may be incorrect."
fi

# Prepare result report
if [[ "$l_output" == *"No valid package repositories found."* ]]; then
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
