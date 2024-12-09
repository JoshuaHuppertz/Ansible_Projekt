#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.2.4"

# Initialize result variable
l_output=""

# Check if the "shadow" group exists and list its members
shadow_group_membership=$(sudo awk -F: '($1=="shadow") {print $NF}' /etc/group)

if [ -n "$shadow_group_membership" ]; then
    l_output+="\n- The \"shadow\" group has members: $shadow_group_membership."
fi

# Check if users have "shadow" as their primary group
shadow_gid=$(getent group shadow | sudo awk -F: '{print $3}')

if [ -n "$shadow_gid" ]; then
    while IFS= read -r l_user; do
        l_user_check=$(awk -F: '($4 == '"$shadow_gid"') {print " - user: \"" $1 "\" primary group is the shadow group"}' /etc/passwd)
        if [ -n "$l_user_check" ]; then
            l_output+="$l_user_check\n"
        fi
    done < <(getent passwd | cut -d: -f1)  # Iterate over all users
fi

# Check the result and output it
if [ -z "$l_output" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- No users were found in the \"shadow\" group."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
