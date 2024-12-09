#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.3.2.3"

# Initialize output variables
l_output=""
l_output2=""

# Get the output of iptables
iptables_rules=$(sudo iptables -L -v -n)

# Define expected rules for new outbound and established connections
expected_rules=(
    "ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0          ct state NEW,RELATED,ESTABLISHED"
    "ACCEPT     udp  --  *      *       0.0.0.0/0            0.0.0.0/0          ct state NEW,RELATED,ESTABLISHED"
    "ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0          ct state NEW,RELATED,ESTABLISHED"
)

# Verify expected rules in iptables output
for rule in "${expected_rules[@]}"; do
    if echo "$iptables_rules" | grep -q "$rule"; then
        l_output+="\n- Found expected rule: $rule"
    else
        l_output2+="\n- Missing expected rule: $rule"
    fi
done

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n$l_output2\n"
    [ -n "$l_output" ] && RESULT+="\n- Correctly set:\n$l_output\n"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"
