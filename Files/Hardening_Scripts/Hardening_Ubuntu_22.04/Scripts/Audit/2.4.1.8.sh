#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.4.1.8"

# Check the status of /etc/cron.allow
cron_allow_stat=$(stat -Lc 'Access: (%a/%A) Owner: (%U) Group: (%G)' /etc/cron.allow 2>/dev/null)

# Prepare the result report
RESULT=""

# Check if /etc/cron.allow exists and meets criteria
if [ -e "/etc/cron.allow" ]; then
    if [[ "$cron_allow_stat" =~ "Access: (640/-rw-r-----)" ]] && [[ "$cron_allow_stat" =~ "Owner: (root)" ]] && [[ "$cron_allow_stat" =~ "Group: (root)" ]]; then
        RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n /etc/cron.allow exists and permissions are correctly set.\n"
        FILE_NAME="$RESULT_DIR/pass.txt"
    else
        RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
        RESULT+="- Reason: /etc/cron.allow does not have the correct permissions or ownership.\n"
        RESULT+="- Current Status: \n$cron_allow_stat\n"
        FILE_NAME="$RESULT_DIR/fail.txt"
    fi
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    RESULT+="- /etc/cron.allow does not exist.\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Check /etc/cron.deny
if [ -e "/etc/cron.deny" ]; then
    cron_deny_stat=$(stat -Lc 'Access: (%a/%A) Owner: (%U) Group: (%G)' /etc/cron.deny 2>/dev/null)
    
    if [[ "$cron_deny_stat" =~ "Access: (640/-rw-r-----)" ]] && [[ "$cron_deny_stat" =~ "Owner: (root)" ]] && [[ "$cron_deny_stat" =~ "Group: (root)" ]]; then
        RESULT+="\n- /etc/cron.deny exists and permissions are correctly set.\n"
    else
        RESULT+="\n- /etc/cron.deny exists but does not have the correct permissions or ownership.\n"
        RESULT+="- Current Status: \n$cron_deny_stat\n"
    fi
else
    RESULT+="\n- /etc/cron.deny does not exist, which is acceptable.\n"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
