#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="6.1.2"

# Initialize result variables
l_output=""
l_output2=""

# Function to check the cron job configuration
check_cron_job() {
    # Check if a cron job for aide exists
    if grep -Prs '^([^#\n\r]+\h+)?(\/usr\/s?bin\/|^\h*)aide(\.wrapper)?\h+(--(check|update)|([^#\n\r]+\h+)?\$AIDEARGS)\b' /etc/cron.* /etc/crontab /var/spool/cron/; then
        l_output+="\n- A valid cron job for aide was found."
    else
        l_output2+="\n- No valid cron job for aide was found."
    fi
}

# Function to check aidecheck.service and aidecheck.timer
check_aidecheck_service() {
    # Check if aidecheck.service is enabled
    if systemctl is-enabled aidecheck.service &>/dev/null; then
        l_output+="\n- aidecheck.service is enabled."
    else
        l_output2+="\n- aidecheck.service is not enabled."
    fi

    # Check if aidecheck.timer is enabled
    if systemctl is-enabled aidecheck.timer &>/dev/null; then
        l_output+="\n- aidecheck.timer is enabled."
    else
        l_output2+="\n- aidecheck.timer is not enabled."
    fi

    # Check if aidecheck.timer is active
    if systemctl is-active aidecheck.timer &>/dev/null; then
        l_output+="\n- aidecheck.timer is running."
    else
        l_output2+="\n- aidecheck.timer is not running."
    fi
}

# Perform the audit
check_cron_job
check_aidecheck_service

# Check result and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n *** PASS ***\n- * Correctly configured *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- * Reasons for failure * :\n$l_output2"
    [ -n "$l_output" ] && RESULT+="\n- * Correctly configured *:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
