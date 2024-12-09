#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.1.3"

# Initialize output variables
l_output=""
l_output2=""

# Check if ufw service is enabled
if systemctl is-enabled ufw.service &>/dev/null; then
    l_output="$l_output\n- ufw.service is enabled"
else
    l_output2="$l_output2\n- ufw.service is not enabled"
fi

# Check if ufw service is active
if systemctl is-active ufw &>/dev/null; then
    l_output="$l_output\n- ufw.service is active"
else
    l_output2="$l_output2\n- ufw.service is not active"
fi

# Check if ufw status is active
ufw_status=$(ufw status | grep -i "Status: active")
if [ -n "$ufw_status" ]; then
    l_output="$l_output\n- ufw status is active"
else
    l_output2="$l_output2\n- ufw status is not active"
fi

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Correctly set:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
