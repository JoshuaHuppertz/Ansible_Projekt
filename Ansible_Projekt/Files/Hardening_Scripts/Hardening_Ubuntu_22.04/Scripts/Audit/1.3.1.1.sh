#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.3.1.1"

# Initialize output variables
l_output=""
l_apparmor_check=""
l_apparmor_utils_check=""

# Check if apparmor is installed
if dpkg-query -s apparmor &>/dev/null; then
    l_apparmor_check="apparmor is installed"
else
    l_apparmor_check="apparmor is not installed"
fi

# Check if apparmor-utils is installed
if dpkg-query -s apparmor-utils &>/dev/null; then
    l_apparmor_utils_check="apparmor-utils is installed"
else
    l_apparmor_utils_check="apparmor-utils is not installed"
fi

# Compile output
l_output+="- $l_apparmor_check\n"
l_output+="- $l_apparmor_utils_check\n"

# Prepare result report
if [[ "$l_apparmor_check" == *"not installed"* ]] || [[ "$l_apparmor_utils_check" == *"not installed"* ]]; then
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
