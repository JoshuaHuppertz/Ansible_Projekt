#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.3.2.4"

# Initialize output variables
l_output=""
l_output2=""

# Determine open ports
open_ports=$(ss -4tuln)

# Determine firewall rules
firewall_rules=$(sudo iptables -L INPUT -v -n)

# Check for open ports listening on non-localhost addresses
non_local_ports=$(echo "$open_ports" | sudo awk '/LISTEN|UNCONN/ && !/127.0.0.1|::1/' | sudo awk '{print $5}' | cut -d':' -f2)

# Verify that each non-local port has a corresponding firewall rule
for port in $non_local_ports; do
    if echo "$firewall_rules" | grep -q "dpt:$port"; then
        l_output+="\n- Firewall rule found for non-local port: $port"
    else
        l_output2+="\n- Missing firewall rule for non-local port: $port"
    fi
done

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
