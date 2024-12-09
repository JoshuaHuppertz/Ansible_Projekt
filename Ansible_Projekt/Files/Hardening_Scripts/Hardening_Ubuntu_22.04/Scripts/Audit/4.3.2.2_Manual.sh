#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.3.2.2"

# Initialize output variables
l_output=""
l_output2=""

# Check INPUT chain
input_rules=$(sudo iptables -L INPUT -v -n)
expected_input_rules=(
    "Chain INPUT (policy DROP 0 packets, 0 bytes)"
    "ACCEPT all -- lo * 0.0.0.0/0 0.0.0.0/0"
    "DROP all -- * * 127.0.0.0/8 0.0.0.0/0"
)

# Verify expected INPUT rules
for rule in "${expected_input_rules[@]}"; do
    if echo "$input_rules" | grep -q "$rule"; then
        l_output+="\n- Found expected INPUT rule: $rule"
    else
        l_output2+="\n- Missing expected INPUT rule: $rule"
    fi
done

# Check OUTPUT chain
output_rules=$(sudo iptables -L OUTPUT -v -n)
expected_output_rules=(
    "Chain OUTPUT (policy DROP 0 packets, 0 bytes)"
    "ACCEPT all -- * lo 0.0.0.0/0 0.0.0.0/0"
)

# Verify expected OUTPUT rules
for rule in "${expected_output_rules[@]}"; do
    if echo "$output_rules" | grep -q "$rule"; then
        l_output+="\n- Found expected OUTPUT rule: $rule"
    else
        l_output2+="\n- Missing expected OUTPUT rule: $rule"
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
