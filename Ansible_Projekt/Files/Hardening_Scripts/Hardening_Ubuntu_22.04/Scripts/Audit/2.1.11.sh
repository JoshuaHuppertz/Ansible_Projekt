#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.11"

# Initialize output variables
output_cups_installed=""
output_enabled=""
output_active=""

# Check if cups is installed
if dpkg-query -s cups &>/dev/null; then
    output_cups_installed="cups is installed"
fi

# If the package is installed, check its service status
if [[ -n "$output_cups_installed" ]]; then
    # Check if cups.socket and cups.service are enabled
    if systemctl is-enabled cups.socket cups.service 2>/dev/null | grep -q 'enabled'; then
        output_enabled="cups.socket and cups.service are enabled"
    fi

    # Check if cups.socket and cups.service are active
    if systemctl is-active cups.socket cups.service 2>/dev/null | grep -q '^active'; then
        output_active="cups.socket and cups.service are active"
    fi
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_cups_installed" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- cups is not installed.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    if [[ -n "$output_cups_installed" ]]; then
        RESULT+="\n- $output_cups_installed\n"
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