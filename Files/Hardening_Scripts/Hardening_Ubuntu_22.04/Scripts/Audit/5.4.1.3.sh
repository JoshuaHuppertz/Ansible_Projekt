#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="5.4.1.3"

# Initialize output variable
output=""

# Function to check PASS_WARN_AGE in /etc/login.defs
CHECK_PASS_WARN_AGE_LOGIN_DEFS() {
    pass_warn_age_check=$(sudo grep -Pi -- '^\h*PASS_WARN_AGE\h+\d+\b' /etc/login.defs)
    
    if [[ "$pass_warn_age_check" =~ ([0-9]+) ]]; then
        warn_age_value="${BASH_REMATCH[1]}"
        if (( warn_age_value >= 7 )); then
            output+="PASS_WARN_AGE in /etc/login.defs is set to: $warn_age_value (PASS)\n"
        else
            output+="PASS_WARN_AGE in /etc/login.defs is set to: $warn_age_value (FAIL)\n"
        fi
    else
        output+="PASS_WARN_AGE is not set in /etc/login.defs (FAIL)\n"
    fi
}

# Function to check PASS_WARN_AGE for all users
CHECK_PASS_WARN_AGE_SHADOW() {
    shadow_check=$(sudo awk -F: '($2~/^\$.+\$/) {if($6 < 7)print "User: " $1 " PASS_WARN_AGE: " $6}' /etc/shadow)
    
    if [ -z "$shadow_check" ]; then
        output+="All users have PASS_WARN_AGE set to 7 or more (PASS)\n"
    else
        output+="Found users with PASS_WARN_AGE less than 7:\n$shadow_check (FAIL)\n"
    fi
}

# Perform the checks
CHECK_PASS_WARN_AGE_LOGIN_DEFS
CHECK_PASS_WARN_AGE_SHADOW

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
