#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.3.16"

# Initialize result variables
l_output=""
l_output2=""

# Check on-disk configuration
on_disk_output=""

# Check on-disk audit rules for /usr/bin/setfacl
if UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs) && [ -n "${UID_MIN}" ]; then
    if awk "/^ *-a *always,exit/ \
    &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
    &&/ -F *auid>=${UID_MIN}/ \
    &&/ -F *perm=x/ \
    &&/ -F *path=\/usr\/bin\/setfacl/ \
    &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)" /etc/audit/rules.d/*.rules 2>/dev/null; then
        on_disk_output+="OK: On-disk audit rules for /usr/bin/setfacl found.\n"
    else
        on_disk_output+="Warning: On-disk audit rules for /usr/bin/setfacl not found.\n"
    fi
else
    on_disk_output+="ERROR: 'UID_MIN' variable is unset.\n"
fi

# Check on-disk configuration results
if [[ "$on_disk_output" == *"Warning:"* || "$on_disk_output" == *"ERROR:"* ]]; then
    l_output2+="\n- Error in on-disk configuration:\n$on_disk_output"
else
    l_output+="\n- On-disk rules are correctly configured:\n$on_disk_output"
fi

# Check running configuration
running_output=""

# Check active audit rules for /usr/bin/setfacl
if UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs) && [ -n "${UID_MIN}" ]; then
    if auditctl -l 2>/dev/null | awk "/^ *-a *always,exit/ \
    &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
    &&/ -F *auid>=${UID_MIN}/ \
    &&/ -F *perm=x/ \
    &&/ -F *path=\/usr\/bin\/setfacl/ \
    &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)"; then
        running_output+="OK: Running audit rules for /usr/bin/setfacl found.\n"
    else
        running_output+="Warning: Running audit rules for /usr/bin/setfacl not found.\n"
    fi
else
    running_output+="ERROR: 'UID_MIN' variable is unset.\n"
fi

# Check running configuration results
if [[ "$running_output" == *"Warning:"* || "$running_output" == *"ERROR:"* ]]; then
    l_output2+="\n- Error in running configuration:\n$running_output"
else
    l_output+="\n- Running rules are correctly configured:\n$running_output"
fi

# Check final result and output
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"