#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.1.1"

# Initialize result variables
l_output=""
l_output2=""

# Check if auditd is installed
if dpkg-query -s auditd &>/dev/null; then
    l_output+="\n- auditd is installed."
else
    l_output2+="\n- auditd is not installed."
fi

# Check if audispd-plugins is installed
if dpkg-query -s audispd-plugins &>/dev/null; then
    l_output+="\n- audispd-plugins are installed."
else
    l_output2+="\n- audispd-plugins are not installed."
fi

# Check results and generate output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
