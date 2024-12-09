#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.2.2"

# Initialize result variable
l_output=""

# Check for users with empty passwords
l_check_output=$(sudo awk -F: '($2 == "") { print $1 " does not have a password" }' /etc/shadow 2>/dev/null)

# Check if awk was able to access /etc/shadow file
if [ $? -ne 0 ]; then
    l_output="Error: Unable to read /etc/shadow file. You may need root privileges."
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** ERROR **\n$l_output"
    FILE_NAME="$RESULT_DIR/error.txt"
elif [ -z "$l_check_output" ]; then
    l_output="- All users have set a password."
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    l_output="- The following users do not have a password:\n$l_check_output"
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure of the check:$l_output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"