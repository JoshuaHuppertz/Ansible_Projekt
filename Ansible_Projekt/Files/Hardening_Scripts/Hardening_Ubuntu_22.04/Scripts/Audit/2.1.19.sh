#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.19"

# Initialize output variables
output_xinetd_installed=""
output_xinetd_enabled=""
output_xinetd_active=""

# Check if xinetd is installed
if dpkg-query -s xinetd &>/dev/null; then
    output_xinetd_installed="xinetd is installed"
fi

# If the package is installed, check its service status
if [[ -n "$output_xinetd_installed" ]]; then
    # Check if xinetd.service is enabled
    if systemctl is-enabled xinetd.service 2>/dev/null | grep -q 'enabled'; then
        output_xinetd_enabled="xinetd.service is enabled"
    fi

    # Check if xinetd.service is active
    if systemctl is-active xinetd.service 2>/dev/null | grep -q '^active'; then
        output_xinetd_active="xinetd.service is active"
    fi
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_xinetd_installed" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- The xinetd package is not installed.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    if [[ -n "$output_xinetd_installed" ]]; then
        RESULT+="\n- $output_xinetd_installed\n"
    fi
    if [[ -n "$output_xinetd_enabled" ]]; then
        RESULT+="\n- $output_xinetd_enabled\n"
    fi
    if [[ -n "$output_xinetd_active" ]]; then
        RESULT+="\n- $output_xinetd_active\n"
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