#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.3.1.3"

# Initialize output variables
l_output=""
l_output2=""

# Check if ufw is installed
if dpkg-query -s ufw &>/dev/null; then
    l_output2+="\n- ufw is installed."
else
    l_output+="\n- ufw is not installed."
fi

# Check if ufw is disabled
ufw_status=$(ufw status | awk '/^Status:/ {print $2}')

if [[ "$ufw_status" == "inactive" ]]; then
    l_output+="\n- ufw is disabled."
else
    l_output2+="\n- ufw is active."
fi

# Check if ufw service is masked
ufw_service_status=$(systemctl is-enabled ufw 2>/dev/null)

if [[ "$ufw_service_status" == "masked" ]]; then
    l_output+="\n- ufw service is masked."
else
    l_output2+="\n- ufw service is not masked."
fi

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output2\n"
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
