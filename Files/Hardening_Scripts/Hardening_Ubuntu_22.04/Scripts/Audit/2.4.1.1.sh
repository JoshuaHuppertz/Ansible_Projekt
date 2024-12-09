#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.4.1.1"

# Initialize output variables
cron_enabled=""
cron_active=""

# Check if cron is enabled
cron_enabled=$(systemctl list-unit-files | awk '$1~/^crond?\.service/{print $2}')
cron_active=$(systemctl list-units | awk '$1~/^crond?\.service/{print $3}')

# Prepare the result report
RESULT=""

if [[ "$cron_enabled" == "enabled" ]] && [[ "$cron_active" == "active" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n- Cron is enabled and active on the system.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    [[ "$cron_enabled" != "enabled" ]] && RESULT+="- Cron service is not enabled.\n"
    [[ "$cron_active" != "active" ]] && RESULT+="- Cron service is not active.\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
