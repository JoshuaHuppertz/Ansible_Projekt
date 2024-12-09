#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.1.10"

# Initialize result variables
l_output=""
l_output2=""

# Check permissions, UID, and GID of the /etc/security/opasswd file
l_opasswd_file="/etc/security/opasswd"
if [ -e "$l_opasswd_file" ]; then
    l_stat_output=$(stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' "$l_opasswd_file")
    
    # Check if the permission is 600 or more restrictive
    if [[ "$l_stat_output" =~ Access:\ \(([^/]+)\/ ]]; then
        l_permissions="${BASH_REMATCH[1]}"
        if [ "$l_permissions" -gt 600 ]; then
            l_output2+="\n- File: \"$l_opasswd_file\" has permission: \"$l_permissions\" (should be 600 or more restrictive)"
        else
            l_output+="\n- File: \"$l_opasswd_file\" has the required permissions: \"$l_permissions\"."
        fi
    fi
    
    # Check UID and GID
    if [[ "$l_stat_output" =~ Uid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_uid="${BASH_REMATCH[1]}"
        l_user="${BASH_REMATCH[2]}"
        if [ "$l_uid" -ne 0 ]; then
            l_output2+="\n- File: \"$l_opasswd_file\" has UID: \"$l_uid\" (should be 0/root)"
        fi
    fi
    
    if [[ "$l_stat_output" =~ Gid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_gid="${BASH_REMATCH[1]}"
        l_group="${BASH_REMATCH[2]}"
        if [ "$l_gid" -ne 0 ]; then
            l_output2+="\n- File: \"$l_opasswd_file\" has GID: \"$l_gid\" (should be 0/root)"
        fi
    fi
else
    l_output+="\n- File: \"$l_opasswd_file\" does not exist."
fi

# Check permissions, UID, and GID of the /etc/security/opasswd.old file
l_opasswd_old_file="/etc/security/opasswd.old"
if [ -e "$l_opasswd_old_file" ]; then
    l_stat_output=$(stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' "$l_opasswd_old_file")
    
    # Check if the permission is 600 or more restrictive
    if [[ "$l_stat_output" =~ Access:\ \(([^/]+)\/ ]]; then
        l_permissions="${BASH_REMATCH[1]}"
        if [ "$l_permissions" -gt 600 ]; then
            l_output2+="\n- File: \"$l_opasswd_old_file\" has permission: \"$l_permissions\" (should be 600 or more restrictive)"
        else
            l_output+="\n- File: \"$l_opasswd_old_file\" has the required permissions: \"$l_permissions\"."
        fi
    fi
    
    # Check UID and GID
    if [[ "$l_stat_output" =~ Uid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_uid="${BASH_REMATCH[1]}"
        l_user="${BASH_REMATCH[2]}"
        if [ "$l_uid" -ne 0 ]; then
            l_output2+="\n- File: \"$l_opasswd_old_file\" has UID: \"$l_uid\" (should be 0/root)"
        fi
    fi
    
    if [[ "$l_stat_output" =~ Gid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_gid="${BASH_REMATCH[1]}"
        l_group="${BASH_REMATCH[2]}"
        if [ "$l_gid" -ne 0 ]; then
            l_output2+="\n- File: \"$l_opasswd_old_file\" has GID: \"$l_gid\" (should be 0/root)"
        fi
    fi
else
    l_output+="\n- File: \"$l_opasswd_old_file\" does not exist."
fi

# Check result and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure of the check:$l_output2"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
