#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.1.5"

# Initialize output variable
output=""

# Function to check the default INACTIVE value using 'useradd -D'
CHECK_DEFAULT_INACTIVE() {
    inactive_default=$(useradd -D | grep -Po '(?<=INACTIVE=)\d+')
    
    if [[ "$inactive_default" -le 45 && "$inactive_default" -ge 0 ]]; then
        output+="Default INACTIVE value is set to $inactive_default (PASS)\n"
    else
        output+="Default INACTIVE value is not within policy limits ($inactive_default) (FAIL)\n"
    fi
}

# Function to check INACTIVE values for all users in /etc/shadow
CHECK_USER_INACTIVE_VALUES() {
    inactive_violations=$(sudo awk -F: '($2~/^\$.+\$/) {if($7 > 45 || $7 < 0)print "User: " $1 " INACTIVE: " $7}' /etc/shadow)
    
    if [[ -z "$inactive_violations" ]]; then
        output+="All users have INACTIVE values within policy limits (PASS)\n"
    else
        output+="Some users have INACTIVE values outside policy limits (FAIL)\n$inactive_violations\n"
    fi
}

# Perform the checks
CHECK_DEFAULT_INACTIVE
CHECK_USER_INACTIVE_VALUES

# Prepare the final result
RESULT=""

# Determine PASS or FAIL based on the output
if echo "$output" | grep -q "(FAIL)"; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$output"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$output"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
