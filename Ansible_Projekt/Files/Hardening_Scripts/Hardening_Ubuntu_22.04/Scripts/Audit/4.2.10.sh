#!/usr/bin/env bash

# Define the result directory
RESULT_DIR="$(dirname "$0")/../../Results"
mkdir -p "$RESULT_DIR"  # Create directory if it doesn't exist

# Define the audit number
AUDIT_NUMBER="4.2.10"

# Initialize output variables
l_output=""
l_output2=""

# Function to check the specified base chain
check_chain() {
    local chain_name=$1
    local expected_output=$2

    # Extract the specified chain from the nftables config
    local chain_output
    chain_output=$(grep -E '^\s*include' /etc/nftables.conf | awk '{ gsub("\"","",$2); print $2 }' | xargs -I {} awk "/hook $chain_name/,/}/" {})

    # Check if the output matches the expected output
    if [[ "$chain_output" == *"$expected_output"* ]]; then
        l_output+="\n- $chain_name base chain is correctly configured:\n$chain_output"
    else
        l_output2+="\n- $chain_name base chain is not correctly configured:\n$chain_output"
    fi
}

# Check input chain
expected_input="type filter hook input priority 0; policy drop;"
check_chain "input" "$expected_input"

# Check forward chain
expected_forward="type filter hook forward priority 0; policy drop;"
check_chain "forward" "$expected_forward"

# Check output chain
expected_output="type filter hook output priority 0; policy drop;"
check_chain "output" "$expected_output"

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
