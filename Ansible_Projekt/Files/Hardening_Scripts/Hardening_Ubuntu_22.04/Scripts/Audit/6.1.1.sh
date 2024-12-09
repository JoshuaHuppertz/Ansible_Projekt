#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="6.1.1"

# Initialize result variables
l_output=""
l_output2=""

# Function to check if aide and aide-common are installed
check_aide_installation() {
    # Check if aide is installed
    if dpkg-query -s aide &>/dev/null; then
        l_output+="\n- aide is installed"
    else
        l_output2+="\n- aide is not installed"
    fi

    # Check if aide-common is installed
    if dpkg-query -s aide-common &>/dev/null; then
        l_output+="\n- aide-common is installed"
    else
        l_output2+="\n- aide-common is not installed"
    fi
}

# Perform the audit
check_aide_installation

# Check result and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n *** PASS ***\n- * Correctly configured *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for failure * :\n$l_output2"
    [ -n "$l_output" ] && RESULT+="\n- * Correctly configured *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
