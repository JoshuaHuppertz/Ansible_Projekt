#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.2.5"

# Initialize result variable
l_output=""

# Check for duplicate UIDs
while read -r l_count l_uid; do
    if [ "$l_count" -gt 1 ]; then
        l_output+="\n- Duplicate UID: \"$l_uid\" Users: \"$(sudo awk -F: '($3 == n) { print $1 }' n="$l_uid" /etc/passwd | xargs)\""
    fi
done < <(cut -f3 -d":" /etc/passwd | sort -n | uniq -c)

# Check the result and output it
if [ -z "$l_output" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- No duplicate UIDs found."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
