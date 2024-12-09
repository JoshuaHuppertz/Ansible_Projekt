#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.1.2"

# Initialize output variable
output=""

# Function to check PASS_MIN_DAYS in /etc/login.defs
CHECK_PASS_MIN_AGE_LOGIN_DEFS() {
    pass_min_days_check=$(sudo grep -Pi -- '^\h*PASS_MIN_DAYS\h+\d+\b' /etc/login.defs)
    
    if [[ "$pass_min_days_check" =~ ([0-9]+) ]]; then
        min_days_value="${BASH_REMATCH[1]}"
        if (( min_days_value > 0 )); then
            output+="PASS_MIN_DAYS in /etc/login.defs is set to: $min_days_value (PASS)\n"
        else
            output+="PASS_MIN_DAYS in /etc/login.defs is set to: $min_days_value (FAIL)\n"
        fi
    else
        output+="PASS_MIN_DAYS is not set in /etc/login.defs (FAIL)\n"
    fi
}

# Function to check PASS_MIN_DAYS for all users
CHECK_PASS_MIN_AGE_SHADOW() {
    shadow_check=$(sudo awk -F: '($2~/^\$.+\$/) {if($4 < 1)print "User: " $1 " PASS_MIN_DAYS: " $4}' /etc/shadow)
    
    if [ -z "$shadow_check" ]; then
        output+="All users have PASS_MIN_DAYS set to greater than 0 (PASS)\n"
    else
        output+="Found users with PASS_MIN_DAYS less than 1:\n$shadow_check (FAIL)\n"
    fi
}

# Perform the checks
CHECK_PASS_MIN_AGE_LOGIN_DEFS
CHECK_PASS_MIN_AGE_SHADOW

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
