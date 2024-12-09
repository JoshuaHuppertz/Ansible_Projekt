#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.1.3"

# Initialize output variables
output=""
version_check=""

# Function to check the version of libpam-pwquality
CHECK_LIBPAM_PWQUALITY() {
    # Check the version of libpam-pwquality
    output=$(sudo dpkg-query -s libpam-pwquality 2>/dev/null | grep -P -- '^(Status|Version)\b')
    
    if [ $? -eq 0 ]; then
        version_check=$(echo "$output" | grep -oP 'Version:\s+\K\S+')
        
        # Construct the output to show the version
        output="Status: installed\nVersion: $version_check"
    else
        output="libpam-pwquality is not installed."
    fi
}

# Perform the check
CHECK_LIBPAM_PWQUALITY

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "installed"; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
