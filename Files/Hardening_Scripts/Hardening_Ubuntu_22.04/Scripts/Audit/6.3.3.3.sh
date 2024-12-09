#!/usr/bin/env bash

# Set result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Set audit number
AUDIT_NUMBER="6.3.3.3"

# Initialize result variables
l_output=""
l_output2=""

# Check on-disk rules
SUDO_LOG_FILE=$(sudo grep -r logfile /etc/sudoers* | sed -e 's/.*logfile=//;s/,? .*$//' -e 's/"//g' -e 's|/|\\/|g')

if [ -n "${SUDO_LOG_FILE}" ]; then
    l_disk_rules_output=$(sudo awk "/^ *-w/ && /${SUDO_LOG_FILE}/ && / -p *wa/ && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)" /etc/audit/rules.d/*.rules 2>/dev/null)
    
    expected_disk_rules="-w ${SUDO_LOG_FILE} -p wa -k sudo_log_file"

    if [ "$l_disk_rules_output" == "$expected_disk_rules" ]; then
        l_output+="\n- On-Disk rules are correctly configured:\n$l_disk_rules_output"
    else
        l_output2+="\n- On-Disk rules are not correctly configured:\n$l_disk_rules_output"
        l_output2+="\n- Expected on-disk rules:\n$expected_disk_rules\n"
    fi
else
    l_output2+="\n- Error: On-Disk 'SUDO_LOG_FILE' variable is not set.\n"
fi

# Check running rules
if [ -n "${SUDO_LOG_FILE}" ]; then
    l_running_rules_output=$(sudo auditctl -l | sudo awk "/^ *-w/ && /${SUDO_LOG_FILE}/ && / -p *wa/ && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)" 2>/dev/null)
    
    expected_running_rules="-w ${SUDO_LOG_FILE} -p wa -k sudo_log_file"

    if [ "$l_running_rules_output" == "$expected_running_rules" ]; then
        l_output+="\n- Running rules are correctly configured:\n$l_running_rules_output"
    else
        l_output2+="\n- Running rules are not correctly configured:\n$l_running_rules_output"
        l_output2+="\n- Expected running rules:\n$expected_disk_rules\n"
    fi
else
    l_output2+="\n- Error: Running rules 'SUDO_LOG_FILE' variable is not set.\n"
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

# Write the result to the appropriate file
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
