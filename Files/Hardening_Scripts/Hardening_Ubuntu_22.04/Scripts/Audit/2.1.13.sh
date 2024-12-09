#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.13"

# Initialize output variables
output_rsync_installed=""
output_enabled=""
output_active=""

# Check if rsync is installed
if dpkg-query -s rsync &>/dev/null; then
    output_rsync_installed="rsync is installed"
fi

# If the package is installed, check its service status
if [[ -n "$output_rsync_installed" ]]; then
    # Check if rsync.service is enabled
    if systemctl is-enabled rsync.service 2>/dev/null | grep -q 'enabled'; then
        output_enabled="rsync.service is enabled"
    fi

    # Check if rsync.service is active
    if systemctl is-active rsync.service 2>/dev/null | grep -q '^active'; then
        output_active="rsync.service is active"
    fi
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_rsync_installed" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- rsync is not installed.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    if [[ -n "$output_rsync_installed" ]]; then
        RESULT+="\n- $output_rsync_installed\n"
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