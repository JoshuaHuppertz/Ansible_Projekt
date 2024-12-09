#!/usr/bin/env bash

# Set the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.2.1.1.2"

# Initialize result variables
l_output=""
l_output2=""

# Check if an override file exists
override_file="/etc/tmpfiles.d/systemd.conf"
default_file="/usr/lib/tmpfiles.d/systemd.conf"

if [ -f "$override_file" ]; then
    l_output="Override file found: $override_file. This file overrides the default values."
    inspected_file="$override_file"
else
    l_output="No override file found. Using the default file: $default_file."
    inspected_file="$default_file"
fi

# Check file permissions
permissions=$(stat -c "%a" "$inspected_file")
if [[ "$permissions" -ge 640 ]]; then
    l_output="$l_output\nFile permissions for \"$inspected_file\": $permissions - Permissions are correct."
else
    l_output2="$l_output2\nFile permissions for \"$inspected_file\": $permissions-  Permissions are not sufficiently restrictive."
fi

# Check the result and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- * Correctly configured * :$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for failure * :$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- * Correctly configured * :\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
