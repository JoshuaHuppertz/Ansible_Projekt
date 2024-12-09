#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.4.1"
USERNAME="<username>"  # Replace <username> with the expected superuser name

# Initialize output variables
l_output=""
superuser_status="PASS"
password_status="PASS"

# Generate expected output for the audit commands
expected_superuser_output="set superusers=\"$USERNAME\""
expected_password_output="password_pbkdf2 $USERNAME grub.pbkdf2.sha512"

# Check for superuser setting
superuser_output=$(grep "^set superusers" /boot/grub/grub.cfg)
if [[ "$superuser_output" != "$expected_superuser_output" ]]; then
    superuser_status="FAIL"
    l_output+="- Superuser setting does not match expected username.\n"
else
    l_output+="- Superuser is set to '$USERNAME'.\n"
fi

# Check for password hash
password_output=$(awk -F. '/^\s*password/ {print $1"."$2"."$3}' /boot/grub/grub.cfg)
if [[ "$password_output" != "$expected_password_output"* ]]; then
    password_status="FAIL"
    l_output+="- Password setting does not match expected hash.\n"
else
    l_output+="- Password is correctly set for '$USERNAME'.\n"
fi

# Compile the result in the desired format
l_output="\n$l_output"
l_output+="- Commands to run and expected results:\n"
l_output+="- # grep \"^set superusers\" /boot/grub/grub.cfg\n"
l_output+="- Expected Output: \"$expected_superuser_output\"\n"
l_output+="- # awk -F. '/^\\s*password/ {print $1\".\"$2\".\"$3}' /boot/grub/grub.cfg\n"
l_output+="- Expected Output: \"$expected_password_output\"\n"

# Determine overall result based on statuses
if [[ "$superuser_status" == "FAIL" ]] || [[ "$password_status" == "FAIL" ]]; then
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