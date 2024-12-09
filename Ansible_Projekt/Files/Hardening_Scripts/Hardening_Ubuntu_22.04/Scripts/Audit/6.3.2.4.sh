#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.2.4"

# Initialize result variables
l_output=""
l_output2=""

# Check if space_left_action is set to email, exec, single, or halt
l_space_left_action_output=$(sudo grep -Pi '^\s*space_left_action\s*=\s*(email|exec|single|halt)\b' /etc/audit/auditd.conf)

if [ -n "$l_space_left_action_output" ]; then
    l_output+="\n- The 'space_left_action' parameter is correctly set: $l_space_left_action_output."
else
    l_output2+="\n- The 'space_left_action' parameter is not set or is misconfigured (it should be set to email, exec, single, or halt)."
fi

# Check if admin_space_left_action is set to single or halt
l_admin_space_left_action_output=$(sudo grep -Pi '^\s*admin_space_left_action\s*=\s*(single|halt)\b' /etc/audit/auditd.conf)

if [ -n "$l_admin_space_left_action_output" ]; then
    l_output+="\n- The 'admin_space_left_action' parameter is correctly set: $l_admin_space_left_action_output."
else
    l_output2+="\n- The 'admin_space_left_action' parameter is not set or is misconfigured (it should be set to single or halt)."
fi

# Check results and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
