#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.16"

# Initialize output variables
output_tftpd_hpa_installed=""
output_enabled=""
output_active=""

# Check if tftpd-hpa is installed
if dpkg-query -s tftpd-hpa &>/dev/null; then
    output_tftpd_hpa_installed="tftpd-hpa is installed"
fi

# If the package is installed, check its service status
if [[ -n "$output_tftpd_hpa_installed" ]]; then
    # Check if tftpd-hpa.service is enabled
    if systemctl is-enabled tftpd-hpa.service 2>/dev/null | grep -q 'enabled'; then
        output_enabled="tftpd-hpa.service is enabled"
    fi

    # Check if tftpd-hpa.service is active
    if systemctl is-active tftpd-hpa.service 2>/dev/null | grep -q '^active'; then
        output_active="tftpd-hpa.service is active"
    fi
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_tftpd_hpa_installed" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- tftpd-hpa is not installed.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    if [[ -n "$output_tftpd_hpa_installed" ]]; then
        RESULT+="\n- $output_tftpd_hpa_installed\n"
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