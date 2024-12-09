#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.3.20"

# Initialize result variables
l_output=""
l_output2=""

# Check on-disk audit rule configuration
on_disk_output=""

# Ensure the audit rules directory exists
if [ -d "/etc/audit/rules.d/" ]; then
    # Check if there are any .rules files in the directory
    if ls /etc/audit/rules.d/*.rules &>/dev/null; then
        # Check the last line of the audit rules for '-e 2'
        if sudo grep -Ph -- '^\h*-e\h+2\b' /etc/audit/rules.d/*.rules | tail -1 | grep -q '^-e 2$'; then
            on_disk_output+="OK: Audit rule '-e 2' is configured correctly.\n"
        else
            on_disk_output+="Warning: Audit rule '-e 2' is not configured correctly.\n"
        fi
    else
        on_disk_output+="Warning: No .rules files found in /etc/audit/rules.d/.\n"
    fi
else
    on_disk_output+="ERROR: Directory '/etc/audit/rules.d/' does not exist.\n"
fi

# Check on-disk configuration results
if [[ "$on_disk_output" == *"Warning:"* || "$on_disk_output" == *"ERROR:"* ]]; then
    l_output2+="\n- Error in the on-disk configuration:\n$on_disk_output"
else
    l_output+="\n- On-disk rules are correctly configured:\n$on_disk_output"
fi

# Check and output the result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
