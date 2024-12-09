#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.1"

# Initialize output variables
output_installed=""
output_enabled=""
output_active=""

# Check if autofs is installed
if dpkg-query -s autofs &>/dev/null; then
    output_installed="autofs is installed"
fi

# If autofs is installed, check its service status
if [[ -n "$output_installed" ]]; then
    # Check if autofs.service is enabled
    if systemctl is-enabled autofs.service 2>/dev/null | grep -q 'enabled'; then
        output_enabled="autofs.service is enabled"
    fi

    # Check if autofs.service is active
    if systemctl is-active autofs.service 2>/dev/null | grep -q '^active'; then
        output_active="autofs.service is active"
    fi
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_installed" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- autofs is not installed.\n"
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