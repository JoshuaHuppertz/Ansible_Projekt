#!/usr/bin/env bash

# Set the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.3.3.11"

# Initialize result variables
l_output=""
l_output2=""

# Check the on-disk configuration
on_disk_output=""

# Check on-disk audit rules for session files (utmp, wtmp, btmp)
if awk "/^ *-w/ \
&&(/\/var\/run\/utmp/ \
||/\/var\/log\/wtmp/ \
||/\/var\/log\/btmp/) \
&&/ +-p *wa/ \
&&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)" /etc/audit/rules.d/*.rules 2>/dev/null; then
    on_disk_output+="OK: On-disk audit rules for session files found.\n"
else
    on_disk_output+="Warning: On-disk audit rules for session files not found.\n"
fi

# Check on-disk configuration results
if [[ "$on_disk_output" == *"Warning:"* ]]; then
    l_output2+="\n- Error in on-disk configuration:\n$on_disk_output"
else
    l_output+="\n- On-disk rules are correctly configured:\n$on_disk_output"
fi

# Check the running configuration
running_output=""

# Check active audit rules for session files (utmp, wtmp, btmp)
if auditctl -l 2>/dev/null | awk "/^ *-w/ \
&&(/\/var\/run\/utmp/ \
||/\/var\/log\/wtmp/ \
||/\/var\/log\/btmp/) \
&&/ +-p *wa/ \
&&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)"; then
    running_output+="OK: Running audit rules for session files found.\n"
else
    running_output+="Warning: Running audit rules for session files not found.\n"
fi

# Check running configuration results
if [[ "$running_output" == *"Warning:"* ]]; then
    l_output2+="\n- Error in running configuration:\n$running_output"
else
    l_output+="\n- Running rules are correctly configured:\n$running_output"
fi

# Check and output the final result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
