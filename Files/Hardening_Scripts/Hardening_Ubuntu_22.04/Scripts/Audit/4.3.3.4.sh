#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.3.3.4"

# Initialize output variables
l_output=""
l_output2=""

# Check open ports
open_ports=$(ss -6tuln)

# Check firewall rules
iptables_output=$(sudo ip6tables -L INPUT -v -n)

# Verify all open ports listening on non-localhost addresses have firewall rules
if echo "$open_ports" | sudo grep -q 'tcp LISTEN.*:::22'; then
    if echo "$iptables_output" | sudo grep -q 'tcp dpt:22 state NEW'; then
        l_output+="\n- Firewall rule for TCP port 22 is present."
    else
        l_output2+="\n- Missing firewall rule for TCP port 22."
    fi
else
    l_output2+="\n- No open TCP ports on non-localhost addresses found."
fi

# Verify IPv6 is disabled
output=""
grubfile="$(sudo find -L /boot -name 'grub.cfg' -type f)"
[ -f "$grubfile" ] && ! sudo grep "^\s*linux" "$grubfile" | sudo grep -vq ipv6.disable=1 && output="IPv6 disabled in grub config"
sudo grep -Eqs "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf && sudo grep -Eqs "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf && sysctl net.ipv6.conf.all.disable_ipv6 | sudo grep -Eq "^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b" && sysctl net.ipv6.conf.default.disable_ipv6 | sudo grep -Eq "^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b" && output="IPv6 disabled in sysctl config"
if [ -n "$output" ]; then
    l_output+="\n$output"
else
    l_output2+="\n*** IPv6 is enabled on the system ***"
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
