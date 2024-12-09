#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.1.7"

# Initialize output variables
l_output=""
l_output2=""

# Function to check UFW default policies
check_ufw_default_policies() {
    # Capture the output of UFW status for default policies
    ufw_policies=$(ufw status verbose | grep "Default:")

    # Check if the output matches the required default policies
    if [[ $ufw_policies =~ "Default: deny" ]] || [[ $ufw_policies =~ "Default: reject" ]] || [[ $ufw_policies =~ "Default: disabled" ]]; then
        l_output+="\n- UFW default policies are correctly set:\n$ufw_policies"
    else
        l_output2+="\n- UFW default policies are incorrectly set:\n$ufw_policies"
    fi
}

# Perform the default policy check
check_ufw_default_policies

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
