#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.2.3"

# Initialize output variables
l_output=""
l_output2=""

# Check iptables rules
iptables_rules=$(iptables -L 2>/dev/null | grep -vE '^Chain|^target')
if [[ -z "$iptables_rules" ]]; then
    l_output="No iptables rules are present"
else
    l_output2="iptables rules are present when none were expected:\n$iptables_rules"
fi

# Check ip6tables rules
ip6tables_rules=$(ip6tables -L 2>/dev/null | grep -vE '^Chain|^target')
if [[ -z "$ip6tables_rules" ]]; then
    l_output+="\nNo ip6tables rules are present"
else
    l_output2+="\nip6tables rules are present when none were expected:\n$ip6tables_rules"
fi

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- $l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n\n- $l_output2\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
