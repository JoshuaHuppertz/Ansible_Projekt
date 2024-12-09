#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.12"

# Initialize output variables
output_rpcbind_installed=""
output_enabled=""
output_active=""

# Check if rpcbind is installed
if dpkg-query -s rpcbind &>/dev/null; then
    output_rpcbind_installed="rpcbind is installed"
fi

# If the package is installed, check its service status
if [[ -n "$output_rpcbind_installed" ]]; then
    # Check if rpcbind.socket and rpcbind.service are enabled
    if systemctl is-enabled rpcbind.socket rpcbind.service 2>/dev/null | grep -q 'enabled'; then
        output_enabled="rpcbind.socket and rpcbind.service are enabled"
    fi

    # Check if rpcbind.socket and rpcbind.service are active
    if systemctl is-active rpcbind.socket rpcbind.service 2>/dev/null | grep -q '^active'; then
        output_active="rpcbind.socket and rpcbind.service are active"
    fi
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_rpcbind_installed" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- rpcbind is not installed.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    if [[ -n "$output_rpcbind_installed" ]]; then
        RESULT+="\n- $output_rpcbind_installed\n"
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