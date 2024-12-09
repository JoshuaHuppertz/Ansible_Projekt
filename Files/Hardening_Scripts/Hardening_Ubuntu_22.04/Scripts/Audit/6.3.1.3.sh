#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.1.3"

# Initialize result variables
l_output=""
l_output2=""

# Check if 'audit=1' is present in grub.cfg, suppress any errors
l_audit_output=$(find /boot -type f -name 'grub.cfg' -exec grep -Ph -- '^\h*linux' {} + 2>/dev/null | grep 'audit=1')

if [ -z "$l_audit_output" ]; then
    l_output+="\n- The parameter 'audit=1' is not present in grub.cfg."
else
    l_output2+="\n- The parameter 'audit=1' is present in grub.cfg."
fi

# Check results and prepare the output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"