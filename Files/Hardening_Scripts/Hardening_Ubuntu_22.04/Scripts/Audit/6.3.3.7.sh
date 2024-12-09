#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.3.7"

# Initialize result variables
l_output=""
l_output2=""

# Get UID_MIN from the configuration
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs 2>/dev/null)

# Check On-Disk configuration
on_disk_output=""

if [ -n "${UID_MIN}" ]; then
    for ARCH in b64 b32; do
        # Check rules for b64 and b32
        for EXIT_CODE in EACCES EPERM; do
            if awk "/^ *-a *always,exit/ \
            &&/ -F *arch=${ARCH}/ \
            &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
            &&/ -F *auid>=${UID_MIN}/ \
            &&(/ -F *exit=-${EXIT_CODE}/) \
            &&/ -S/ \
            &&/creat/ \
            &&/open/ \
            &&/truncate/ \
            &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)" /etc/audit/rules.d/*.rules 2>/dev/null; then
                on_disk_output+="OK: Audit rule for ${ARCH} with exit code ${EXIT_CODE} found.\n"
            else
                on_disk_output+="Warning: Audit rule for ${ARCH} with exit code ${EXIT_CODE} not found.\n"
            fi
        done
    done
else
    on_disk_output="ERROR: Variable 'UID_MIN' is unset.\n"
fi

# Check On-Disk configuration results
if [[ "$on_disk_output" == *"Warning:"* ]]; then
    l_output2+="\n- Error in On-Disk configuration:\n$on_disk_output"
else
    l_output+="\n- On-Disk rules are correctly configured:\n$on_disk_output"
fi

# Check Running configuration
running_output=""

if [ -n "${UID_MIN}" ]; then
    RUNNING=$(auditctl -l 2>/dev/null)

    if [ -n "${RUNNING}" ]; then
        for ARCH in b64 b32; do
            for EXIT_CODE in EACCES EPERM; do
                if printf -- "${RUNNING}" | awk "/^ *-a *always,exit/ \
                &&/ -F *arch=${ARCH}/ \
                &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
                &&/ -F *auid>=${UID_MIN}/ \
                &&(/ -F *exit=-${EXIT_CODE}/) \
                &&/ -S/ \
                &&/creat/ \
                &&/open/ \
                &&/truncate/ \
                &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)/ 2>/dev/null"; then
                    running_output+="OK: Running rule for ${ARCH} with exit code ${EXIT_CODE} found.\n"
                else
                    running_output+="Warning: Running rule for ${ARCH} with exit code ${EXIT_CODE} not found.\n"
                fi
            done
        done
    else
        running_output="ERROR: Variable 'RUNNING' is unset.\n"
    fi
else
    running_output="ERROR: Variable 'UID_MIN' is unset.\n"
fi

# Check Running configuration results
if [[ "$running_output" == *"Warning:"* || "$running_output" == *"ERROR:"* ]]; then
    l_output2+="\n- Error in Running configuration:\n$running_output"
else
    l_output+="\n- Running rules are correctly configured:\n$running_output"
fi

# Check and output result
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