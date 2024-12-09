#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.2.3"

# Initialize result variable
l_output=""

# Extract GIDs from /etc/passwd and /etc/group
a_passwd_group_gid=($(sudo awk -F: '{print $4}' /etc/passwd | sort -u))
a_group_gid=($(sudo awk -F: '{print $3}' /etc/group | sort -u))
a_passwd_group_diff=($(printf '%s\n' "${a_group_gid[@]}" "${a_passwd_group_gid[@]}" | sort | uniq -u))

# Check GIDs
while IFS= read -r l_gid; do
    l_check_output=$(sudo awk -F: '($4 == '"$l_gid"') {print " - User: \"" $1 "\" has GID: \"" $4 "\" which does not exist in /etc/group"}' /etc/passwd)
    
    # Store the result if the GID does not exist
    if [ -n "$l_check_output" ]; then
        l_output+="$l_check_output\n"
    fi
done < <(printf '%s\n' "${a_passwd_group_gid[@]}" "${a_passwd_group_diff[@]}" | sort | uniq -D | uniq)

# Check the result and output it
if [ -z "$l_output" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- All GIDs in /etc/passwd exist in /etc/group."
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure of the check:\n$l_output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
