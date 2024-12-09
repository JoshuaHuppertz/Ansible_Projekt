#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.2.6"

# Initialize output variables
l_output=""
l_output2=""

# Check for loopback interface rules
loopback_accept=$(nft list ruleset 2>/dev/null | awk '/hook input/,/}/' | grep -E 'iif "lo" accept')
ipv4_drop=$(nft list ruleset 2>/dev/null | awk '/hook input/,/}/' | grep -E 'ip saddr 127\.0\.0\.0/8 .* drop')
ipv6_drop=""

# Check if IPv6 is enabled, and if so, check for IPv6 loopback drop rule
if [[ -f /proc/net/if_inet6 ]]; then
    ipv6_drop=$(nft list ruleset 2>/dev/null | awk '/hook input/,/}/' | grep -E 'ip6 saddr ::1 .* drop')
fi

# Verify rules
if [[ -n "$loopback_accept" ]]; then
    l_output+="\n- Loopback interface is configured to accept traffic:\n$loopback_accept"
else
    l_output2+="\n- Loopback interface is not configured to accept traffic as expected"
fi

if [[ -n "$ipv4_drop" ]]; then
    l_output+="\n- IPv4 loopback traffic is configured to drop:\n$ipv4_drop"
else
    l_output2+="\n- IPv4 loopback traffic is not configured to drop as expected"
fi

if [[ -f /proc/net/if_inet6 ]]; then
    if [[ -n "$ipv6_drop" ]]; then
        l_output+="\n- IPv6 loopback traffic is configured to drop:\n$ipv6_drop"
    else
        l_output2+="\n- IPv6 loopback traffic is not configured to drop as expected"
    fi
fi

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
