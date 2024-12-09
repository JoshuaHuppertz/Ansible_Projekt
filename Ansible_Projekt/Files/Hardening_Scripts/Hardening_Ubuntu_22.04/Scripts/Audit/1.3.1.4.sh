#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.3.1.4"

# Initialize output variables
l_output=""
l_profile_check=""
l_process_check=""

# Check AppArmor profiles with sudo
profile_output=$(sudo apparmor_status | grep profiles)
if echo "$profile_output" | grep -q "profiles are loaded"; then
    # Check if all profiles are in enforce mode
    if echo "$profile_output" | grep -q "0 profiles are in complain mode"; then
        l_profile_check="All profiles are loaded and in enforce mode."
    else
        l_profile_check="Some profiles are in complain mode."
    fi
else
    l_profile_check="No profiles are loaded."
fi

# Check AppArmor processes with sudo
process_output=$(sudo apparmor_status | grep processes)
if echo "$process_output" | grep -q "processes are defined"; then
    if echo "$process_output" | grep -q "0 processes are unconfined"; then
        l_process_check="No unconfined processes are present."
    else
        l_process_check="There are unconfined processes."
    fi
else
    l_process_check="No processes are defined."
fi

# Compile output
l_output+="- $l_profile_check\n"
l_output+="- $l_process_check\n"

# Determine overall result
if [[ "$l_profile_check" == *"FAIL"* ]] || [[ "$l_process_check" == *"FAIL"* ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the file and also display it on the console
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
