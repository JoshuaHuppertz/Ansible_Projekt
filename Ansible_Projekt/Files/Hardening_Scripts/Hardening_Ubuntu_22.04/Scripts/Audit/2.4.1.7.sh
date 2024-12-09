#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.4.1.7"

# Check the status of /etc/cron.d
cron_d_stat=$(stat -Lc 'Access: (%a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' /etc/cron.d)

# Prepare the result report
RESULT=""

# Check for UID, GID, and Access permissions
if [[ "$cron_d_stat" =~ "Access: (700/drwx------)" ]] && [[ "$cron_d_stat" =~ "Uid: (0/ root)" ]] && [[ "$cron_d_stat" =~ "Gid: (0/ root)" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n /etc/cron.d permissions are correctly set.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    RESULT+="- /etc/cron.d permissions are incorrectly set or not owned by root.\n"
    RESULT+="- Current Status: \n$cron_d_stat\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
