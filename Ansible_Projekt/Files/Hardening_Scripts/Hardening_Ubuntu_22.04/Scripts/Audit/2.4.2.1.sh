#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.4.2.1"

# Prepare the result report
RESULT=""

# Check the status of /etc/at.allow
at_allow_stat=$(stat -Lc 'Access: (%a/%A) Owner: (%U) Group: (%G)' /etc/at.allow 2>/dev/null)

# Check if /etc/at.allow exists and meets criteria
if [ -f "/etc/at.allow" ]; then
    if [[ "$at_allow_stat" == "Access: (640/-rw-r-----)" && ("$at_allow_stat" == *"Group: (daemon)" || "$at_allow_stat" == *"Group: (root)") ]]; then
        RESULT+="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n /etc/at.allow exists and permissions are correctly set.\n"
        FILE_NAME="$RESULT_DIR/pass.txt"
    else
        RESULT+="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
        RESULT+="- /etc/at.allow does not have the correct permissions or ownership.\n"
        RESULT+="- Current Status: \n$at_allow_stat\n"
        FILE_NAME="$RESULT_DIR/fail.txt"
    fi
else
    RESULT+="- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    RESULT+="- /etc/at.allow does not exist.\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Check /etc/at.deny
if [ -f "/etc/at.deny" ]; then
    at_deny_stat=$(stat -Lc 'Access: (%a/%A) Owner: (%U) Group: (%G)' /etc/at.deny 2>/dev/null)
    
    if [[ "$at_deny_stat" == "Access: (640/-rw-r-----)" && ("$at_deny_stat" == *"Group: (daemon)" || "$at_deny_stat" == *"Group: (root)") ]]; then
        RESULT+="\n- /etc/at.deny exists and permissions are correctly set.\n"
    else
        RESULT+="\n- /etc/at.deny exists but does not have the correct permissions or ownership.\n"
        RESULT+="- Current Status: \n$at_deny_stat\n"
    fi
else
    RESULT+="\n- /etc/at.deny does not exist, which is acceptable.\n"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"