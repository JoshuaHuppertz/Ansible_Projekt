#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="1.3.1.2"

# Initialize output variables
l_output=""
l_apparmor_param_check=""
l_security_param_check=""

# Check for apparmor=1 in linux lines
if grep "^\s*linux" /boot/grub/grub.cfg | grep -qv "apparmor=1"; then
    l_apparmor_param_check="apparmor = 1 parameter is missing in some linux lines"
else
    l_apparmor_param_check="apparmor = 1 parameter is set in all linux lines"
fi

# Check for security=apparmor in linux lines
if grep "^\s*linux" /boot/grub/grub.cfg | grep -qv "security=apparmor"; then
    l_security_param_check="security = apparmor parameter is missing in some linux lines"
else
    l_security_param_check="security = apparmor parameter is set in all linux lines"
fi

# Compile output
l_output+="- $l_apparmor_param_check\n"
l_output+="- $l_security_param_check\n"

# Determine overall result
if [[ "$l_apparmor_param_check" == *"FAIL"* ]] || [[ "$l_security_param_check" == *"FAIL"* ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
