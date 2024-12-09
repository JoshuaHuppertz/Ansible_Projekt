#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.3.19"

# Initialize result variables
l_output=""
l_output2=""

# Check on-disk configuration
on_disk_output=""

# Check on-disk rules for kernel modules
if sudo awk '/^ *-a *always,exit/ \
&&/ -F *arch=b(32|64)/ \
&&(/ -F auid!=unset/||/ -F auid!=-1/||/ -F auid!=4294967295/) \
&&/ -S/ \
&&(/init_module/ \
||/finit_module/ \
||/delete_module/) \
&&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules 2>/dev/null; then
    on_disk_output+="OK: On-disk audit rules for kernel modules found.\n"
else
    on_disk_output+="Warning: On-disk audit rules for kernel modules not found.\n"
fi

# Check UID_MIN for kmod
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
if [ -n "${UID_MIN}" ]; then
    if sudo awk "/^ *-a *always,exit/ \
    &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
    &&/ -F *auid>=${UID_MIN}/ \
    &&/ -F *perm=x/ \
    &&/ -F *path=\/usr\/bin\/kmod/ \
    &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)" /etc/audit/rules.d/*.rules 2>/dev/null; then
        on_disk_output+="OK: On-disk audit rules for /usr/bin/kmod found.\n"
    else
        on_disk_output+="Warning: On-disk audit rules for /usr/bin/kmod not found.\n"
    fi
else
    on_disk_output+="ERROR: Variable 'UID_MIN' is unset.\n"
fi

# Check results of on-disk configuration
if [[ "$on_disk_output" == *"Warning:"* || "$on_disk_output" == *"ERROR:"* ]]; then
    l_output2+="\n- Error in the on-disk configuration:\n$on_disk_output"
else
    l_output+="\n- On-disk rules are correctly configured:\n$on_disk_output"
fi

# Check running configuration
running_output=""

# Check active audit rules for kernel modules
if sudo auditctl -l | sudo awk '/^ *-a *always,exit/ \
&&/ -F *arch=b(32|64)/ \
&&(/ -F auid!=unset/||/ -F auid!=-1/||/ -F *auid!=4294967295/) \
&&/ -S/ \
&&(/init_module/ \
||/finit_module/ \
||/delete_module/) \
&&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)' 2>/dev/null; then
    running_output+="OK: Running audit rules for kernel modules found.\n"
else
    running_output+="Warning: Running audit rules for kernel modules not found.\n"
fi

# Check UID_MIN for kmod
if [ -n "${UID_MIN}" ]; then
    if sudo auditctl -l | sudo awk "/^ *-a *always,exit/ \
    &&(/ -F *auid!=unset/||/ -F *auid!=-1/||/ -F *auid!=4294967295/) \
    &&/ -F *auid>=${UID_MIN}/ \
    &&/ -F *perm=x/ \
    &&/ -F *path=\/usr\/bin\/kmod/ \
    &&(/ key= *[!-~]* *$/||/ -k *[!-~]* *$/)" 2>/dev/null; then
        running_output+="OK: Running audit rules for /usr/bin/kmod found.\n"
    else
        running_output+="Warning: Running audit rules for /usr/bin/kmod not found.\n"
    fi
else
    running_output+="ERROR: Variable 'UID_MIN' is unset.\n"
fi

# Check results of running configuration
if [[ "$running_output" == *"Warning:"* || "$running_output" == *"ERROR:"* ]]; then
    l_output2+="\n- Error in the running configuration:\n$running_output"
else
    l_output+="\n- Running rules are correctly configured:\n$running_output"
fi

# Symlink check
symlink_output=""
S_LINKS=$(sudo ls -l /usr/sbin/lsmod /usr/sbin/rmmod /usr/sbin/insmod /usr/sbin/modinfo /usr/sbin/modprobe /usr/sbin/depmod | grep -vE " -> (\.\./)?bin/kmod" || true)
if [[ "${S_LINKS}" != "" ]]; then
    symlink_output="Issue with symlinks:\n${S_LINKS}\n"
else
    symlink_output="OK: All symlinks are correctly pointing to /usr/bin/kmod.\n"
fi

# Check symlink results
if [[ "$symlink_output" == *"Issue with symlinks:"* ]]; then
    l_output2+="\n- Error in symlinks:\n$symlink_output"
else
    l_output+="\n- Symlinks are correctly configured:\n$symlink_output"
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
