#!/usr/bin/env bash

# Set the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.3.3.9"

# Initialize result variables
l_output=""
l_output2=""

# Check the on-disk configuration
on_disk_output=""

# Check on-disk audit rules
if UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs 2>/dev/null); then
    if [ -n "${UID_MIN}" ]; then
        if awk "/^ *-a *always,exit/ \
        &&/ -F *arch=b(32|64)/ \
        &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
        &&/ -S/ \
        &&/ -F *auid>=${UID_MIN}/ \
        &&(/chmod/||/fchmod/||/fchmodat/ \
        ||/chown/||/fchown/||/fchownat/||/lchown/ \
        ||/setxattr/||/lsetxattr/||/fsetxattr/ \
        ||/removexattr/||/lremovexattr/||/fremovexattr/) \
        &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)" /etc/audit/rules.d/*.rules 2>/dev/null; then
            on_disk_output+="OK: On-disk audit rules found.\n"
        else
            on_disk_output+="Warning: On-disk audit rules not found for permission modification syscalls.\n"
        fi
    else
        on_disk_output+="ERROR: Variable 'UID_MIN' is unset.\n"
    fi
else
    on_disk_output+="ERROR: Unable to read UID_MIN.\n"
fi

# Check on-disk configuration results
if [[ "$on_disk_output" == *"Warning:"* || "$on_disk_output" == *"ERROR:"* ]]; then
    l_output2+="\n- Error in on-disk configuration:\n$on_disk_output"
else
    l_output+="\n- On-disk rules are correctly configured:\n$on_disk_output"
fi

# Check the running configuration
running_output=""

# Check active audit rules
if UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs 2>/dev/null); then
    if [ -n "${UID_MIN}" ]; then
        if auditctl -l 2>/dev/null | awk "/^ *-a *always,exit/ \
        &&/ -F *arch=b(32|64)/ \
        &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
        &&/ -S/ \
        &&/ -F *auid>=${UID_MIN}/ \
        &&(/chmod/||/fchmod/||/fchmodat/ \
        ||/chown/||/fchown/||/fchownat/||/lchown/ \
        ||/setxattr/||/lsetxattr/||/fsetxattr/ \
        ||/removexattr/||/lremovexattr/||/fremovexattr/) \
        &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)"; then
            running_output+="OK: Running audit rules found.\n"
        else
            running_output+="Warning: Running audit rules not found for permission modification syscalls.\n"
        fi
    else
        running_output+="ERROR: Variable 'UID_MIN' is unset.\n"
    fi
else
    running_output+="ERROR: Unable to read UID_MIN.\n"
fi

# Check running configuration results
if [[ "$running_output" == *"Warning:"* || "$running_output" == *"ERROR:"* ]]; then
    l_output2+="\n- Error in running configuration:\n$running_output"
else
    l_output+="\n- Running rules are correctly configured:\n$running_output"
fi

# Check and output the final result
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
