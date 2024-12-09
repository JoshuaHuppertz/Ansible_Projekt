#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.1.1"

# Initialize output variables
output=""
version_check=""

# Function to check the version of libpam-runtime
CHECK_LIBPAM_RUNTIME() {
    # Check the version of libpam-runtime
    output=$(sudo dpkg-query -s libpam-runtime | sudo grep -P -- '^(Status|Version)\b')
    
    if [ $? -eq 0 ]; then
        version_check=$(echo "$output" | sudo grep -oP 'Version:\s+\K\S+')
        if [ -n "$version_check" ]; then
            output="Status: installed\nVersion: $version_check"
        fi
    else
        output="libpam-runtime is not installed."
    fi
}

# Perform the check
CHECK_LIBPAM_RUNTIME

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | sudo grep -q "installed"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
