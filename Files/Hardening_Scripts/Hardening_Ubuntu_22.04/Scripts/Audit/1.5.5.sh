#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.5.5"

# Initialize output variables
l_output=""
l_output2=""

# Function to check if Apport is installed and enabled
check_apport() {
    # Check if Apport is installed
    if dpkg-query -s apport &> /dev/null; then
        # Check if Apport is enabled
        if grep -Psi -- '^\h*enabled\h*=\h*[^0]\b' /etc/default/apport &> /dev/null; then
            l_output2="$l_output2\n- Apport is enabled."
        else
            l_output="$l_output\n- Apport is not enabled."
        fi
    else
        l_output="$l_output\n- Apport is not installed."
    fi
}

# Function to check if the Apport service is active
check_apport_service() {
    if systemctl is-active apport.service | grep '^active' &> /dev/null; then
        l_output2="$l_output2\n- Apport service is active."
    else
        l_output="$l_output\n- Apport service is not active."
    fi
}

# Run the checks
check_apport
check_apport_service

# Prepare result report
if [ -z "$l_output2" ]; then
    # PASS: No issues found
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    # FAIL: Issues found
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
