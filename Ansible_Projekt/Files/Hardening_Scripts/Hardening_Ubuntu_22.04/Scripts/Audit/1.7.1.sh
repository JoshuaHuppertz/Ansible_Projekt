#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.7.1"

# Initialize output variables
l_output=""
l_output2=""

# Function to check if gdm3 is installed
check_gdm3_installed() {
        
    # Check if gdm3 is installed
    if dpkg-query -s gdm3 &>/dev/null; then
        l_output2="\n- gdm3 is installed"
    else
        l_output="\n- gdm3 is not installed"
    fi
}

# Run the check
check_gdm3_installed

# Prepare result report
if [ -z "$l_output2" ]; then
    # PASS: gdm3 is not installed
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    # FAIL: gdm3 is installed
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"