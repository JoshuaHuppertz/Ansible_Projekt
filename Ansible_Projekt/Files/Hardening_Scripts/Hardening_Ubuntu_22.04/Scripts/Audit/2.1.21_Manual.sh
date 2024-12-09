#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="2.1.21"

# Initialize output variables
output_port_list=()
output_non_loopback_ports=""

# Define ports to check
a_port_list=("25" "465" "587")

# Check if inet_interfaces is not set to all
# Redirect stderr to /dev/null to suppress error messages (e.g., 'main.cf not found')
if [ "$(postconf -n inet_interfaces 2>/dev/null)" != "inet_interfaces = all" ]; then
    for l_port_number in "${a_port_list[@]}"; do
        # Check if the port is listening on a non-loopback network interface
        if ss -plntu | grep -P -- ':'"$l_port_number"'\b' | grep -Pvq -- '\h+(127\.0\.0\.1|\[?::1\]?):'"$l_port_number"'\b'; then
            output_non_loopback_ports+=" - Port \"$l_port_number\" is listening on a non-loopback network interface\n"
        else
            output_port_list+=(" - Port \"$l_port_number\" is not listening on a non-loopback network interface")
        fi
    done
else
    output_non_loopback_ports=" - Postfix is bound to all interfaces"
fi

# Prepare the result report
RESULT=""

if [[ -z "$output_non_loopback_ports" ]]; then
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** PASS **\n\n- All checked ports are not listening on non-loopback interfaces.\n"
    FILE_NAME="$RESULT_DIR/pass.txt"
else
    RESULT="\n- Audit: $AUDIT_NUMBER\n\n- Audit Result:\n ** FAIL **\n"
    RESULT+="\n- $output_non_loopback_ports"
    [ "${#output_port_list[@]}" -gt 0 ] && RESULT+="\n- Correctly set:\n$(printf "%s\n" "${output_port_list[@]}")"
    FILE_NAME="$RESULT_DIR/fail.txt"
fi

# Write the result to the file (no console output)
{
    echo -e "$RESULT"
    # Add a separator line
    echo -e "-------------------------------------------------"
} >> "$FILE_NAME"
#echo -e "$RESULT"