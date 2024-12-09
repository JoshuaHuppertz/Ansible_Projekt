#!/usr/bin/env bash

# Set the results directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.3.4.7"

# Initialize result variables
l_output=""
l_output2=""

# Check if the audit configuration files belong to the group "root"
while IFS= read -r -d $'\0' l_fname; do
    l_output2+="\n- File: \"$l_fname\" does not belong to group: \"root\""
done < <(sudo find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) ! -group root -print0 2>/dev/null)

# Check and output the result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- All audit configuration files belong to group: \"root\"."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
