#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.3"

# Initialize output variables
output_installed=""
output_enabled=""
output_active=""

# Check if isc-dhcp-server is installed
if dpkg-query -s isc-dhcp-server &>/dev/null; then
    output_installed="isc-dhcp-server is installed"
fi

# If isc-dhcp-server is installed, check its service status
if [[ -n "$output_installed" ]]; then
    # Check if isc-dhcp-server.service and isc-dhcp-server6.service are enabled
    if systemctl is-enabled isc-dhcp-server.service isc-dhcp-server6.service 2>/dev/null | grep -q 'enabled'; then
        output_enabled="isc-dhcp-server.service and/or isc-dhcp-server6.service are enabled"
    fi

    # Check if isc-dhcp-server.service and isc-dhcp-server6.service are active
    if systemctl is-active isc-dhcp-server.service isc-dhcp-server6.service 2>/dev/null | grep -q '^active'; then
        output_active="isc-dhcp-server.service and/or isc-dhcp-server6.service are active"
    fi
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_installed" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- isc-dhcp-server is not installed.\n"
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