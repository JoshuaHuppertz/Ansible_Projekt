#!/usr/bin/env bash

# Set the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.2.1.2.4"

# Initialize result variables
l_output=""
l_output2=""

# Check if systemd-journal-remote.socket and systemd-journal-remote.service are not enabled
l_enabled_output=$(systemctl is-enabled systemd-journal-remote.socket systemd-journal-remote.service 2>/dev/null)
if echo "$l_enabled_output" | grep -q '^enabled'; then
    l_output2+="\n- systemd-journal-remote.socket and/or systemd-journal-remote.service are enabled."
else
    l_output+="\n- systemd-journal-remote.socket and systemd-journal-remote.service are not enabled."
fi

# Check if systemd-journal-remote.socket and systemd-journal-remote.service are not active
l_active_output=$(systemctl is-active systemd-journal-remote.socket systemd-journal-remote.service 2>/dev/null)
if echo "$l_active_output" | grep -q '^active'; then
    l_output2+="\n- systemd-journal-remote.socket and/or systemd-journal-remote.service are active."
else
    l_output+="\n- systemd-journal-remote.socket and systemd-journal-remote.service are not active."
fi

# Check the result and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failing the check:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the corresponding file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
