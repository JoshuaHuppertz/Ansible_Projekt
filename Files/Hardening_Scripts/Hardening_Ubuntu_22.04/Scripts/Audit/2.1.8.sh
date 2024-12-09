#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.8"

# Initialize output variables
output_imapd=""
output_pop3d=""
output_enabled=""
output_active=""

# Check if dovecot-imapd is installed
if dpkg-query -s dovecot-imapd &>/dev/null; then
    output_imapd="dovecot-imapd is installed"
fi

# Check if dovecot-pop3d is installed
if dpkg-query -s dovecot-pop3d &>/dev/null; then
    output_pop3d="dovecot-pop3d is installed"
fi

# If either package is installed, check its service status
if [[ -n "$output_imapd" || -n "$output_pop3d" ]]; then
    # Check if dovecot.socket and dovecot.service are enabled
    if systemctl is-enabled dovecot.socket dovecot.service 2>/dev/null | grep -q 'enabled'; then
        output_enabled="dovecot.socket or dovecot.service is enabled"
    fi

    # Check if dovecot.socket and dovecot.service are active
    if systemctl is-active dovecot.socket dovecot.service 2>/dev/null | grep -q '^active'; then
        output_active="dovecot.socket or dovecot.service is active"
    fi
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_imapd" && -z "$output_pop3d" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- Neither dovecot-imapd nor dovecot-pop3d is installed.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    if [[ -n "$output_imapd" ]]; then
        RESULT+="\n- $output_imapd\n"
    fi
    if [[ -n "$output_pop3d" ]]; then
        RESULT+="\n- $output_pop3d\n"
    fi
    if [[ -n "$output_enabled" ]]; then
        RESULT+="\n- $output_enabled\n"
    fi
    if [[ -n "$output_active" ]]; then
        RESULT+="\n- $output_active\n"
    fi
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"