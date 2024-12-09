#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.2.2"

# Initialize output variables
l_output=""
l_output2=""

# Check if UFW is not installed
if ! dpkg-query -s ufw &>/dev/null; then
    l_output="ufw is not installed"
else
    # If UFW is installed, check if it is disabled and the service is masked
    ufw_status=$(ufw status 2>/dev/null)
    ufw_service_status=$(systemctl is-enabled ufw.service 2>/dev/null)
    
    if [[ "$ufw_status" == "Status: inactive" && "$ufw_service_status" == "masked" ]]; then
        l_output="ufw is installed but is inactive and the service is masked"
    else
        l_output2="ufw is installed, and either active or the service is enabled (expected: inactive and masked)"
    fi
fi

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- $l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n\n- $l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
