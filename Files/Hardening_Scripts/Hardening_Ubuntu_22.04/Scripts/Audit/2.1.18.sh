#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.18"

# Initialize output variables
output_apache_installed=""
output_nginx_installed=""
output_apache_enabled=""
output_nginx_enabled=""
output_apache_active=""
output_nginx_active=""

# Check if apache2 is installed
if dpkg-query -s apache2 &>/dev/null; then
    output_apache_installed="apache2 is installed"
fi

# Check if nginx is installed
if dpkg-query -s nginx &>/dev/null; then
    output_nginx_installed="nginx is installed"
fi

# If either package is installed, check their service statuses
if [[ -n "$output_apache_installed" || -n "$output_nginx_installed" ]]; then
    # Check if apache2.socket and apache2.service are enabled
    if systemctl is-enabled apache2.socket apache2.service 2>/dev/null | grep -q 'enabled'; then
        output_apache_enabled="apache2.socket and/or apache2.service is enabled"
    fi

    # Check if nginx.service is enabled
    if systemctl is-enabled nginx.service 2>/dev/null | grep -q 'enabled'; then
        output_nginx_enabled="nginx.service is enabled"
    fi

    # Check if apache2.socket and apache2.service are active
    if systemctl is-active apache2.socket apache2.service 2>/dev/null | grep -q '^active'; then
        output_apache_active="apache2.socket and/or apache2.service is active"
    fi

    # Check if nginx.service is active
    if systemctl is-active nginx.service 2>/dev/null | grep -q '^active'; then
        output_nginx_active="nginx.service is active"
    fi
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_apache_installed" && -z "$output_nginx_installed" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- Neither apache2 nor nginx is installed.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    if [[ -n "$output_apache_installed" ]]; then
        RESULT+="\n- $output_apache_installed\n"
    fi
    if [[ -n "$output_nginx_installed" ]]; then
        RESULT+="\n- $output_nginx_installed\n"
    fi
    if [[ -n "$output_apache_enabled" ]]; then
        RESULT+="\n- $output_apache_enabled\n"
    fi
    if [[ -n "$output_nginx_enabled" ]]; then
        RESULT+="\n- $output_nginx_enabled\n"
    fi
    if [[ -n "$output_apache_active" ]]; then
        RESULT+="\n- $output_apache_active\n"
    fi
    if [[ -n "$output_nginx_active" ]]; then
        RESULT+="\n- $output_nginx_active\n"
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