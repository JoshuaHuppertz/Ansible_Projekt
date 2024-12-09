#!/usr/bin/env bash

# Set the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.2.1.2.2"

# Initialize result variables
l_output=""
l_output2=""

# Check the configuration for systemd-journal-upload
l_config_file="/etc/systemd/journal-upload.conf"

# Check if the configuration file exists
if [ -f "$l_config_file" ]; then
    l_check_output=$(grep -P "^ *URL=|^ *ServerKeyFile=|^ *ServerCertificateFile=|^ *TrustedCertificateFile=" "$l_config_file")
    
    if [ -n "$l_check_output" ]; then
        l_output="Authentication configuration is present:\n$l_check_output"
    else
        l_output2="No authentication configuration found in $l_config_file."
    fi
else
    l_output2="Configuration file $l_config_file not found."
fi

# Check the result and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
