#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.3.1.2"

# Initialize output variables
output=""
version_check=""

# Function to check the version of libpam-modules
CHECK_LIBPAM_MODULES() {
    # Check the version of libpam-modules
    output=$(sudo dpkg-query -s libpam-modules | sudo grep -P -- '^(Status|Version)\b')
    
    if [ $? -eq 0 ]; then
        version_check=$(echo "$output" | sudo grep -oP 'Version:\s+\K\S+')
        
        # Check if version is 1.5.2-6 or later
        if [[ "$version_check" == 1.5.* || "$version_check" > "1.5.2-6" ]]; then
            output="Status: installed\nVersion: $version_check"
        else
            output="libpam-modules is installed but the version ($version_check) is less than 1.5.2-6."
        fi
    else
        output="libpam-modules is not installed."
    fi
}

# Perform the check
CHECK_LIBPAM_MODULES

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | sudo grep -q "installed"; then
    if [[ "$version_check" == 1.5.* || "$version_check" > "1.5.2-6" ]]; then
        RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$output"
        FILE_NAME="$RESULT_DIR/pass.txt"
    else
        RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
        FILE_NAME="$RESULT_DIR/fail.txt"
    fi
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
