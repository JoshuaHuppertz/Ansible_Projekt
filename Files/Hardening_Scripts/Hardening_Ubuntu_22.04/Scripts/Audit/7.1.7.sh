#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="7.1.7"

# Initialize result variables
l_output=""
l_output2=""

# Check permissions, UID, and GID of the /etc/gshadow file
l_gshadow_file="/etc/gshadow"
if [ -e "$l_gshadow_file" ]; then
    l_stat_output=$(stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' "$l_gshadow_file")
    
    # Check if permissions are 640 or more restrictive
    if [[ "$l_stat_output" =~ Access:\ \(([^/]+)\/ ]]; then
        l_permissions="${BASH_REMATCH[1]}"
        if [ "$l_permissions" -gt 640 ]; then
            l_output2+="\n- File: \"$l_gshadow_file\" has permission: \"$l_permissions\" (should be 640 or more restrictive)"
        else
            l_output+="\n- File: \"$l_gshadow_file\" has the required permissions: \"$l_permissions\"."
        fi
    fi
    
    # Check UID and GID
    if [[ "$l_stat_output" =~ Uid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_uid="${BASH_REMATCH[1]}"
        l_user="${BASH_REMATCH[2]}"
        if [ "$l_uid" -ne 0 ]; then
            l_output2+="\n- File: \"$l_gshadow_file\" has UID: \"$l_uid\" (should be 0/root)"
        fi
    fi
    
    if [[ "$l_stat_output" =~ Gid:\ \ \(([^/]+)\/([^ ]+)\) ]]; then
        l_gid="${BASH_REMATCH[1]}"
        l_group="${BASH_REMATCH[2]}"
        if [ "$l_gid" -ne 0 ] && [ "$l_gid" -ne 42 ]; then
            l_output2+="\n- File: \"$l_gshadow_file\" has GID: \"$l_gid\" (should be 0/root or 42/shadow)"
        fi
    fi
else
    l_output2+="\n- File: \"$l_gshadow_file\" not found."
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
