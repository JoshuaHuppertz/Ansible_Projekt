#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.4.1.5"

# Check the status of /etc/cron.weekly
cron_weekly_stat=$(stat -Lc 'Access: (%a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' /etc/cron.weekly)

# Prepare the result report
RESULT=""

# Check for UID, GID, and Access permissions
if [[ "$cron_weekly_stat" =~ "Access: (700/drwx------)" ]] && [[ "$cron_weekly_stat" =~ "Uid: (0/ root)" ]] && [[ "$cron_weekly_stat" =~ "Gid: (0/ root)" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n /etc/cron.weekly permissions are correctly set.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    RESULT+="- /etc/cron.weekly permissions are incorrectly set or not owned by root.\n"
    RESULT+="- Current Status: \n$cron_weekly_stat\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
