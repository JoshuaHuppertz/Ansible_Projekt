#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.2"

# Initialize output variables
output_installed=""
output_enabled=""
output_active=""

# Check if avahi-daemon is installed
if dpkg-query -s avahi-daemon &>/dev/null; then
    output_installed="avahi-daemon is installed"
fi

# If avahi-daemon is installed, check its service status
if [[ -n "$output_installed" ]]; then
    # Check if avahi-daemon.socket and avahi-daemon.service are enabled
    if systemctl is-enabled avahi-daemon.socket avahi-daemon.service 2>/dev/null | grep -q 'enabled'; then
        output_enabled="avahi-daemon.socket and/or avahi-daemon.service are enabled"
    fi

    # Check if avahi-daemon.socket and avahi-daemon.service are active
    if systemctl is-active avahi-daemon.socket avahi-daemon.service 2>/dev/null | grep -q '^active'; then
        output_active="avahi-daemon.socket and/or avahi-daemon.service are active"
    fi
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_installed" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- avahi-daemon is not installed.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    if [[ -n "$output_installed" ]]; then
        RESULT+="\n- $output_installed\n"
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