#!/usr/bin/env bash

# Install auditd, suppress console output
sudo apt install auditd -y > /dev/null 2>&1

# Set the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create the directory if it doesn't exist

# Set the audit number
AUDIT_NUMBER="6.3.3.1"

# Initialize result variables
l_output=""
l_output2=""

# Define the expected on-disk rules (normalized format)
expected_disk_rules="-w /etc/sudoers -p wa -k scope -w /etc/sudoers.d -p wa -k scope"

# Check the on-disk rules in /etc/audit/rules.d/*.rules
# Suppress error messages if files are missing
l_disk_rules_output=$(sudo awk '/^ *-w/ && /\/etc\/sudoers/ && / +-p *wa/ && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' /etc/audit/rules.d/*.rules 2>/dev/null)

# Normalize the on-disk rules by removing extra spaces
normalized_disk_rules=$(echo "$l_disk_rules_output" | tr -s '[:space:]' ' ')

# Compare the actual on-disk rules with the expected ones
if [ "$normalized_disk_rules" == "$expected_disk_rules" ]; then
    l_output+="\n- On-disk rules are correctly configured:\n$normalized_disk_rules"
else
    l_output2+="\n- On-disk rules are not correctly configured:\n$normalized_disk_rules"
    l_output2+="\n- Expected on-disk rules:\n$expected_disk_rules\n"
fi

# Check the running audit rules using auditctl
l_running_rules_output=$(sudo auditctl -l | awk '/^ *-w/ && /\/etc\/sudoers/ && / +-p *wa/ && (/ key= *[!-~]* *$/ || / -k *[!-~]* *$/)' 2>/dev/null)

# Normalize the running rules output by removing extra spaces
normalized_running_rules=$(echo "$l_running_rules_output" | tr -s '[:space:]' ' ')

# Compare the actual running rules with the expected ones
if [ "$normalized_running_rules" == "$expected_disk_rules" ]; then
    l_output+="\n- Running rules are correctly configured:\n$normalized_running_rules"
else
    l_output2+="\n- Running rules are not correctly configured:\n$normalized_running_rules"
    l_output2+="\n- Expected running rules:\n$expected_disk_rules"
fi

# Check and save the result
if [ -z "$l_output2" ]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reasons for failure:\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Successfully configured:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the appropriate file (pass.txt or fail.txt)
{
    echo -e "$RESULT"
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
