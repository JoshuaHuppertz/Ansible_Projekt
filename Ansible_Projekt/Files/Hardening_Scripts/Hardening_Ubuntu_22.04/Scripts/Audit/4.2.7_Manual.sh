#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.2.7"

# Initialize output variables
l_output=""
l_output2=""

# Expected incoming connection rules (site policy)
expected_incoming=(
  "ip protocol tcp ct state established accept"
  "ip protocol udp ct state established accept"
  "ip protocol icmp ct state established accept"
)

# Expected outgoing connection rules (site policy)
expected_outgoing=(
  "ip protocol tcp ct state established,related,new accept"
  "ip protocol udp ct state established,related,new accept"
  "ip protocol icmp ct state established,related,new accept"
)

# Check for established incoming connection rules
incoming_rules=$(nft list ruleset 2>/dev/null | awk '/hook input/,/}/' | grep -E 'ip protocol (tcp|udp|icmp) ct state')
for rule in "${expected_incoming[@]}"; do
  if echo "$incoming_rules" | grep -q "$rule"; then
    l_output+="\n- Found incoming rule: $rule"
  else
    l_output2+="\n- Missing incoming rule: $rule"
  fi
done

# Check for new and established outgoing connection rules
outgoing_rules=$(nft list ruleset 2>/dev/null | awk '/hook output/,/}/' | grep -E 'ip protocol (tcp|udp|icmp) ct state')
for rule in "${expected_outgoing[@]}"; do
  if echo "$outgoing_rules" | grep -q "$rule"; then
    l_output+="\n- Found outgoing rule: $rule"
  else
    l_output2+="\n- Missing outgoing rule: $rule"
  fi
done

# Prepare the final result
RESULT=""

# Provide output based on the audit checks
if [ -z "$l_output2" ]; then
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n$l_output\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT+="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n\n$l_output2\n"
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
