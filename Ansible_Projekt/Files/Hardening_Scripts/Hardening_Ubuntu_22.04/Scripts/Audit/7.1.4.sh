#!/usr/bin/env bash

# Set the results directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="7.1.4"

# Initialize result variables
l_output=""
l_output2=""

# Check permissions, UID, and GID of the file /etc/group-
l_group_file="/etc/group-"
if [ -e "$l_group_file" ]; then
    l_stat_output=$(stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' "$l_group_file")
    
    # Check if the permission is 644 or more restrictive
    if [[ "$l_stat_output" =~ Access:\ \(([^/]+)\/ ]]; then
        l_permissions="${BASH_REMATCH[1]}"
        if [ "$l_permissions" -gt 644 ]; then
            l_output2+="\n- File: \"$l_group_file\" has permission: \"$l_permissions\" (should be 644 or more restrictive)"
        else
            l_output+="\n- File: \"$l_group_file\" has the required permissions: \"$l_permissions\"."
        fi
    fi
    
    # Check UID
    if [[ "$l_stat_output" =~ Uid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_uid="${BASH_REMATCH[1]}"
        l_user="${BASH_REMATCH[2]}"
        if [ "$l_uid" -ne 0 ]; then
            l_output2+="\n- File: \"$l_group_file\" has UID: \"$l_uid\" (should be 0/root)"
        fi
    fi
    
    # Check GID
    if [[ "$l_stat_output" =~ Gid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_gid="${BASH_REMATCH[1]}"
        l_group="${BASH_REMATCH[2]}"
        if [ "$l_gid" -ne 0 ]; then
            l_output2+="\n- File: \"$l_group_file\" has GID: \"$l_gid\" (should be 0/root)"
        fi
    fi
else
    l_output2+="\n - File: \"$l_group_file\" not found."
fi

# Check and output the result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for audit failure:$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
