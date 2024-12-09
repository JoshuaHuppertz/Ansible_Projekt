#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.3.3.3"

# Initialize output variables
l_output=""
l_output2=""

# Check ip6tables rules
iptables_output=$(sudo ip6tables -L -v -n)

# Check for new outbound and established connections
expected_rules=(
    "ACCEPT ip6 protocol tcp ct state established,related,new"
    "ACCEPT ip6 protocol udp ct state established,related,new"
    "ACCEPT ip6 protocol icmpv6 ct state established,related,new"
)

# Verify the output against expected rules
for rule in "${expected_rules[@]}"; do
    if echo "$iptables_output" | sudo grep -q "$rule"; then
        l_output+="\n- Found expected rule for: $rule"
    else
        l_output2+="\n- Missing expected rule for: $rule"
    fi
done

# Check if IPv6 is enabled
if sudo grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable; then
    l_output2+="\n- IPv6 is enabled on the system."
else
    l_output+="\n- IPv6 is not enabled on the system."
fi

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n- Reason(s) for audit failure:\n$l_output2\n"
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
