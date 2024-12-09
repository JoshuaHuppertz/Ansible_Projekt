#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.2.8"

# Initialize result variable
l_output=""

# Check for duplicate groups
while read -r l_count l_group; do
    if [ "$l_count" -gt 1 ]; then
        l_output+="\n- Duplicate Group: \"$l_group\" Groups: \"$(sudo awk -F: '($1 == n) { print $1 }' n="$l_group" /etc/group | xargs)\""
    fi
done < <(cut -f1 -d":" /etc/group | sort -n | uniq -c)

# Check the result and output it
if [ -z "$l_output" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- No duplicate groups found."
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
