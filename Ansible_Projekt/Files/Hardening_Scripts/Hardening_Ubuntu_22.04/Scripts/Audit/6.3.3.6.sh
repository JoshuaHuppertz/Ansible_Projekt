#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.3.6"

# Initialize result variables
l_output=""
l_output2=""

# Check On-Disk configuration
on_disk_output=""

for PARTITION in $(findmnt -n -l -k -it $(sudo awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,) | grep -Pv "noexec|nosuid" | awk '{print $1}'); do
    for PRIVILEGED in $(find "${PARTITION}" -xdev -perm /6000 -type f); do
        if grep -qr "${PRIVILEGED}" /etc/audit/rules.d; then
            on_disk_output+="OK: '${PRIVILEGED}' found in auditing rules.\n"
        else
            on_disk_output+="Warning: '${PRIVILEGED}' not found in on disk configuration.\n"
        fi
    done
done

# Check On-Disk configuration results
if [[ "$on_disk_output" == *"Warning:"* ]]; then
    l_output2+="\n- Error in On-Disk configuration:\n$on_disk_output"
else
    l_output+="\n- On-Disk rules are correctly configured:\n$on_disk_output"
fi

# Check Running configuration
running_output=""

RUNNING=$(sudo auditctl -l)

if [ -n "${RUNNING}" ]; then
    for PARTITION in $(findmnt -n -l -k -it $(sudo awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,) | grep -Pv "noexec|nosuid" | awk '{print $1}'); do
        for PRIVILEGED in $(sudo find "${PARTITION}" -xdev -perm /6000 -type f); do
            if printf -- "${RUNNING}" | grep -q "${PRIVILEGED}"; then
                running_output+="OK: '${PRIVILEGED}' found in auditing rules.\n"
            else
                running_output+="Warning: '${PRIVILEGED}' not found in running configuration.\n"
            fi
        done
    done
else
    running_output="ERROR: Variable 'RUNNING' is unset.\n"
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
